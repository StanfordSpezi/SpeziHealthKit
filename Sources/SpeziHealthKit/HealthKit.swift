//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SwiftUI


/// The `HealthKit` module enables the collection of HealthKit data.
///
/// The `HealthKit` module simplifies access to HealthKit samples ranging from single, anchored, and background queries.
///
/// Before you configure the ``HealthKit`` module, make sure your `Standard` in your Spezi Application conforms to the ``HealthKitConstraint`` protocol to receive HealthKit data.
/// The ``HealthKitConstraint/add(sample:)`` function is triggered once for every newly collected HealthKit sample, and the ``HealthKitConstraint/remove(sample:)`` function is triggered once for every deleted HealthKit sample.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///    // Add the newly collected HKSample to your application.
///    func add(sample: HKSample) async {
///        ...
///    }
///    // Remove the deleted HKSample from your application.
///    func remove(sample: HKDeletedObject) {
///        ...
///    }
/// }
/// ```
/// 
/// Then, you can configure the ``HealthKit`` module in the configuration section of your `SpeziAppDelegate`.
/// Provide ``HealthKitDataSourceDescription`` to define the data collection.
/// You can, e.g., use ``CollectSample`` to collect a wide variety of `HKSampleTypes`:
/// ```swift
/// class ExampleAppDelegate: SpeziAppDelegate {
///     override var configuration: Configuration {
///         Configuration(standard: ExampleStandard()) {
///             if HKHealthStore.isHealthDataAvailable() {
///                 HealthKit {
///                     CollectSample(
///                         HKQuantityType.electrocardiogramType(),
///                         deliverySetting: .background(.manual)
///                     )
///                     CollectSample(
///                         HKQuantityType(.stepCount),
///                         deliverySetting: .background(.afterAuthorizationAndApplicationWillLaunch)
///                     )
///                     CollectSample(
///                         HKQuantityType(.pushCount),
///                         deliverySetting: .anchorQuery(.manual)
///                     )
///                     CollectSample(
///                         HKQuantityType(.activeEnergyBurned),
///                         deliverySetting: .anchorQuery(.afterAuthorizationAndApplicationWillLaunch)
///                     )
///                     CollectSample(
///                         HKQuantityType(.restingHeartRate),
///                         deliverySetting: .manual()
///                     )
///                 }
///             }
///         }
///     }
/// }
/// ```
@Observable
public final class HealthKit: Module, LifecycleHandler, EnvironmentAccessible, DefaultInitializable {
    @ObservationIgnored @StandardActor private var standard: any HealthKitConstraint
    private let healthStore: HKHealthStore
    private var healthKitDataSourceDescriptions: [HealthKitDataSourceDescription] = []
    @ObservationIgnored private lazy var healthKitComponents: [any HealthKitDataSource] = {
        healthKitDataSourceDescriptions
            .flatMap { $0.dataSources(healthStore: healthStore, standard: standard) }
    }()
    
    private var healthKitSampleTypes: Set<HKSampleType> {
        healthKitDataSourceDescriptions.reduce(into: Set()) {
            $0 = $0.union($1.sampleTypes)
        }
    }
    
    private var healthKitSampleTypesIdentifiers: Set<String> {
        Set(healthKitSampleTypes.map(\.identifier))
    }

    private var alreadyRequestedSampleTypes: Set<String> {
        get {
            access(keyPath: \.alreadyRequestedSampleTypes)
            return Set(UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.healthKitRequestedSampleTypes) ?? [])
        }
        set {
            withMutation(keyPath: \.alreadyRequestedSampleTypes) {
                UserDefaults.standard.set(Array(newValue), forKey: UserDefaults.Keys.healthKitRequestedSampleTypes)
            }
        }
    }
    
    /// Indicates whether the necessary authorizations to collect all HealthKit data defined by the ``HealthKitDataSourceDescription``s are already granted.
    public var authorized: Bool {
        healthKitSampleTypesIdentifiers.isSubset(of: alreadyRequestedSampleTypes)
    }

    
    /// Creates a new instance of the ``HealthKit`` module.
    /// - Parameters:
    ///   - healthKitDataSourceDescriptions: The ``HealthKitDataSourceDescription``s define what data is collected by the ``HealthKit`` module. You can, e.g., use ``CollectSample`` to collect a wide variety of `HKSampleTypes`.
    public convenience init(
        @HealthKitDataSourceDescriptionBuilder _ healthKitDataSourceDescriptions: () -> [HealthKitDataSourceDescription]
    ) {
        self.init()
        
        self.healthKitDataSourceDescriptions = healthKitDataSourceDescriptions()
    }
    
    public init() {
        precondition(
            HKHealthStore.isHealthDataAvailable(),
            """
            HealthKit is not available on this device.
            Check if HealthKit is available e.g., using `HKHealthStore.isHealthDataAvailable()`:
            
            if HKHealthStore.isHealthDataAvailable() {
                HealthKitHealthStore()
            }
            """
        )
        
        self.healthStore = HKHealthStore()
    }
    
    
    /// Displays the user interface to ask for authorization for all HealthKit data defined by the ``HealthKitDataSourceDescription``s.
    ///
    /// Call this function when you want to start HealthKit data collection.
    public func askForAuthorization() async throws {
        guard !authorized else {
            return
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: healthKitSampleTypes)

        alreadyRequestedSampleTypes = healthKitSampleTypesIdentifiers
        
        for healthKitComponent in healthKitComponents {
            // reads the above userDefault!
            healthKitComponent.askedForAuthorization()
        }
    }
    
    public func execute(_ healthKitDataSourceDescription: HealthKitDataSourceDescription) {
        healthKitDataSourceDescriptions.append(healthKitDataSourceDescription)
        let dataSources = healthKitDataSourceDescription.dataSources(healthStore: healthStore, standard: standard)
        for dataSource in dataSources {
            dataSource.willFinishLaunchingWithOptions()
        }
    }
    
    public func execute(@HealthKitDataSourceDescriptionBuilder _ healthKitDataSourceDescriptions: () -> [HealthKitDataSourceDescription]) {
        for healthKitDataSourceDescription in healthKitDataSourceDescriptions() {
            execute(healthKitDataSourceDescription)
        }
    }
    
    
    @_documentation(visibility: internal)
    public func willFinishLaunchingWithOptions(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
        for healthKitComponent in healthKitComponents {
            healthKitComponent.willFinishLaunchingWithOptions()
        }
    }
    
    
    /// Triggers any ``HealthKitDeliverySetting/manual(safeAnchor:)`` collections and starts the collection for all ``HealthKitDeliveryStartSetting/manual`` HealthKit data collections.
    public func triggerDataSourceCollection() async {
        await withTaskGroup(of: Void.self) { group in
            for healthKitComponent in healthKitComponents {
                group.addTask {
                    await healthKitComponent.triggerDataSourceCollection()
                }
            }
            await group.waitForAll()
        }
    }
}
