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


/// The ``HealthKit`` module enables the collection of HealthKit data and transforms it to the component's standard's base type using an `Adapter` (``HealthKit/HKSampleAdapter``)
///
/// Configuration for the ``SpeziHealthKit`` module.
///
/// Make sure that your standard in your Spezi Application conforms to the ``HealthKitConstraint``
/// protocol to receive HealthKit data.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///    func add(_ response: HKSample) async {
///        ...
///    }
///
///    func remove(removalContext: SpeziHealthKit.HKSampleRemovalContext) {
///        ...
///    }
/// }
/// ```
///
/// Use the ``HealthKit/init(_:adapter:)`` initializer to define different ``HealthKitDataSourceDescription``s to define the data collection.
/// You can, e.g., use ``CollectSample`` to collect a wide variaty of `HKSampleTypes`:
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
public final class HealthKit: Module {
    @StandardActor var standard: any HealthKitConstraint
    let healthStore: HKHealthStore
    let healthKitDataSourceDescriptions: [HealthKitDataSourceDescription]
    lazy var healthKitComponents: [any HealthKitDataSource] = {
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
    
    /// Indicates whether the necessary authorizations to collect all HealthKit data defined by the ``HealthKitDataSourceDescription``s are already granted.
    public var authorized: Bool {
        let alreadyRequestedSampleTypes = Set(UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.healthKitRequestedSampleTypes) ?? [])

        return healthKitSampleTypesIdentifiers.isSubset(of: alreadyRequestedSampleTypes)
    }

    
    /// Creates a new instance of the ``HealthKit`` module.
    /// - Parameters:
    ///   - healthKitDataSourceDescriptions: The ``HealthKitDataSourceDescription``s define what data is collected by the ``HealthKit`` module. You can, e.g., use ``CollectSample`` to collect a wide variaty of `HKSampleTypes`.
    ///   - adapter: The ``HealthKit/HKSampleAdapter`` type defines the mapping of `HKSample`s to the component's standard's base type.
    public init(
        @HealthKitDataSourceDescriptionBuilder _ healthKitDataSourceDescriptions: () -> ([HealthKitDataSourceDescription])
    ) {
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
        
        let healthStore = HKHealthStore()
        let healthKitDataSourceDescriptions = healthKitDataSourceDescriptions()
        
        self.healthKitDataSourceDescriptions = healthKitDataSourceDescriptions
        self.healthStore = healthStore
    }
    
    
    /// Displays the user interface to ask for authorization for all HealthKit data defined by the ``HealthKitDataSourceDescription``s.
    ///
    /// Call this function when you want to start HealthKit data collection.
    public func askForAuthorization() async throws {
        guard !authorized else {
            return
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: healthKitSampleTypes)
        
        UserDefaults.standard.set(Array(healthKitSampleTypesIdentifiers), forKey: UserDefaults.Keys.healthKitRequestedSampleTypes)
        
        for healthKitComponent in healthKitComponents {
            healthKitComponent.askedForAuthorization()
        }
        
        // Triggers an update of the UI in case the HealthKit authorizations are changed
        Task { @MainActor in
            self.objectWillChange.send()
        }
    }
    
    
    public func willFinishLaunchingWithOptions(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
        for healthKitComponent in healthKitComponents {
            healthKitComponent.willFinishLaunchingWithOptions(application, launchOptions: launchOptions)
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
