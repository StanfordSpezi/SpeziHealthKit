//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziFoundation
import SwiftUI


/// The `HealthKit` module enables the collection of HealthKit data.
///
/// The `HealthKit` module simplifies access to HealthKit samples ranging from single, anchored, and background queries.
///
/// Before you configure the ``HealthKit`` module, make sure your `Standard` in your Spezi Application conforms to the ``HealthKitConstraint`` protocol to receive HealthKit data.
/// The ``HealthKitConstraint/add(sample:)`` function is triggered once for every newly collected HealthKit sample, and the ``HealthKitConstraint/remove(sample:)`` function is triggered once for every deleted HealthKit sample.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///     // Add the newly collected HKSample to your application.
///     func add(sample: HKSample) async {
///         ...
///     }
///
///     // Remove the deleted HKSample from your application.
///     func remove(sample: HKDeletedObject) {
///         ...
///     }
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
///                         deliverySetting: .background(.automatic)
///                     )
///                     CollectSample(
///                         HKQuantityType(.pushCount),
///                         deliverySetting: .anchorQuery(.manual)
///                     )
///                     CollectSample(
///                         HKQuantityType(.activeEnergyBurned),
///                         deliverySetting: .anchorQuery(.automatic)
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
public final class HealthKit: Module, EnvironmentAccessible, DefaultInitializable {
    @ObservationIgnored @StandardActor private var standard: any HealthKitConstraint
    
    
    @ObservationIgnored @Application(\.logger) private var logger
    
    /// The HealthKit module's underlying `HKHealthStore`.
    /// Users can access this in a `View` via the `@Environment(HealthKit.self)` property wrapper.
    public let healthStore: HKHealthStore
    
    //@MainActor private var initialHealthKitDataSourceDescriptions: [HealthKitDataSourceDescription] = []
    //@MainActor private var healthKitDataSourceDescriptions: [HealthKitDataSourceDescription] = []
    /// All object types the HealthKit module needs access to, based on the configuration components.
    private let healthKitObjectTypes: Set<HKObjectType>
    
    /// Configurations which were supplied to the initializer, but have not yet been applied.
    /// - Note: This property is intended only to store the configuration until `configure()` has been called. It is not used afterwards.
    @ObservationIgnored private var pendingConfiguration: [any HealthKitConfigurationComponent]
    
    @MainActor private var sampleCollectionDescriptors: [any HealthKitSampleCollectionDescriptor] = []
    @ObservationIgnored private var registeredDataSources: [any HealthKitDataSource] = [] // TODO different name! (property&protocol!)
    
    //@MainActor
    public var allAuthorizedObjectTypes: Set<HKObjectType> {
        return HKObjectType.allKnownObjectTypes.filter { (type: HKObjectType) -> Bool in
            self.healthStore.authorizationStatus(for: type) == .sharingAuthorized
        }
    }
    
    /// Indicates whether the necessary authorizations to collect all HealthKit data defined by the ``HealthKitDataSourceDescription``s are already granted.
    @MainActor public var isFullyAuthorized: Bool {
        //healthKitSampleTypesIdentifiers.isSubset(of: alreadyRequestedSampleTypes)
        allAuthorizedObjectTypes.isSuperset(of: healthKitObjectTypes)
    }
    
    
    /// Creates a new instance of the ``HealthKit`` module.
    /// - parameter config: The configuration defines the behaviour of the `HealthKit` module,
    ///     specifying e.g. which samples the app wants to continuously collect (via ``CollectSample`` and ``CollectSamples``,
    ///     and which sample and object types the user should be prompted to grant the app read access to (via ``RequestReadAccess``).
    public init(
        @ArrayBuilder<any HealthKitConfigurationComponent> _ config: () -> [any HealthKitConfigurationComponent]
    ) {
        healthStore = HKHealthStore()
        pendingConfiguration = config()
        healthKitObjectTypes = Set(pendingConfiguration.flatMap(\.accessedObjectTypes))
        
        if !HKHealthStore.isHealthDataAvailable() {
            // If HealthKit is not available, we still initialise the module and the health store as normal.
            // Queries and sample collection, in this case, will simply not return any results.
            logger.error("HealthKit is not available. SpeziHealthKit and its module will still exist in the application, but all HealthKit-related functionality will be disabled.")
        }
    }
    
    
    /// Creates a new instance of the ``HealthKit`` module, with an empty configuration.
    public convenience init() {
        self.init { /* intentionally empty config */ }
    }


    public func configure() {
        for component in pendingConfiguration {
            component.configure(for: self)
        }
    }
    
    
    // MARK: HealthKit authorization handling

    /// Displays the user interface to ask for authorization for all HealthKit data defined by the ``HealthKitDataSourceDescription``s.
    ///
    /// Call this function when you want to start HealthKit data collection.
    @MainActor // TODO why is this MainActor-constrained? so that we can call it from SwiftUI?
    public func askForAuthorization() async throws {
        try await healthStore.requestAuthorization(toShare: Set([HKQuantityTypeIdentifier.heartRate, .stepCount, .oxygenSaturation].map(HKQuantityType.init)), read: healthKitObjectTypes)
        
        for dataSource in registeredDataSources {
            await dataSource.askedForAuthorization()
        }
    }
    
    
    /// Returns whether the user was already asked for authorization to access the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    public func askedForAuthorization(for objectType: HKObjectType) -> Bool {
        healthStore.authorizationStatus(for: objectType) != .notDetermined
    }
    
    
    // MARK: HealthKit data collection

    @MainActor
    public func execute(_ descriptor: some HealthKitSampleCollectionDescriptor) {
        sampleCollectionDescriptors.append(descriptor)
        let dataSources = descriptor.dataSources(healthKit: self, standard: standard)
        for dataSource in dataSources {
            registeredDataSources.append(dataSource)
            Task {
                await dataSource.startAutomaticDataCollection()
            }
        }
    }

    @MainActor
    public func execute(
        @ArrayBuilder<any HealthKitSampleCollectionDescriptor> _ descriptors: () -> [any HealthKitSampleCollectionDescriptor]
    ) {
        for descriptor in descriptors() {
            execute(descriptor)
        }
    }
    
    /// Triggers any ``HealthKitDeliverySetting/manual(safeAnchor:)`` collections and starts the collection for all ``HealthKitDeliveryStartSetting/manual`` HealthKit data collections.
    @MainActor
    public func triggerDataSourceCollection() async {
        await withTaskGroup(of: Void.self) { group in
            for dataSource in registeredDataSources {
                group.addTask { @MainActor @Sendable in
                    await dataSource.triggerManualDataSourceCollection()
                }
            }
            await group.waitForAll()
        }
    }
}





extension HKHealthStore {
    func spezi_requestPerObjectReadAuthorization(for type: HKObjectType, predicate: NSPredicate?) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.requestPerObjectReadAuthorization(for: type, predicate: predicate) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
}
