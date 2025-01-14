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
/// You can, e.g., use ``CollectSample`` to collect a wide variety of ``HealthKitSampleType``s:
/// ```swift
/// class ExampleAppDelegate: SpeziAppDelegate {
///     override var configuration: Configuration {
///         Configuration(standard: ExampleStandard()) {
///             if HKHealthStore.isHealthDataAvailable() {
///                 HealthKit {
///                     CollectSample(
///                         .electrocardiogram,
///                         delivery: .background(.manual)
///                     )
///                     CollectSample(
///                         .stepCount,
///                         delivery: .background(.automatic)
///                     )
///                     CollectSample(
///                         .pushCount,
///                         delivery: .anchorQuery(.manual)
///                     )
///                     CollectSample(
///                         .activeEnergyBurned,
///                         delivery: .anchorQuery(.automatic)
///                     )
///                     CollectSample(
///                         .restingHeartRate,
///                         delivery: .manual()
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
    
    /// Which HealthKit data we need to be able to access, for read and/or write operations.
    private let healthKitDataAccessRequirements: HealthKitDataAccessRequirements
    
    /// Configurations which were supplied to the initializer, but have not yet been applied.
    /// - Note: This property is intended only to store the configuration until `configure()` has been called. It is not used afterwards.
    @ObservationIgnored private var pendingConfiguration: [any HealthKitConfigurationComponent]
    
    /// All 
    @ObservationIgnored private var registeredDataSources: [any HealthKitDataSource] = [] // TODO different name! (property&protocol!)
    
    /// Indicates whether the necessary authorizations to access HealthKit data defined by the ``HealthKitConfigurationComponent``s were requested from the user.
    /// - Note: The fact that authorizations were requested does **not** imply that the user also granted them.
    @MainActor public private(set) var didRequestAuthorization = false
    
    
    /// Creates a new instance of the ``HealthKit`` module.
    /// - parameter config: The configuration defines the behaviour of the `HealthKit` module,
    ///     specifying e.g. which samples the app wants to continuously collect (via ``CollectSample`` and ``CollectSamples``,
    ///     and which sample and object types the user should be prompted to grant the app read access to (via ``RequestReadAccess``).
    public init(
        @ArrayBuilder<any HealthKitConfigurationComponent> _ config: () -> [any HealthKitConfigurationComponent]
    ) {
        if !HKHealthStore.isHealthDataAvailable() {
            // If HealthKit is not available, we still initialise the module and the health store as normal.
            // Queries and sample collection, in this case, will simply not return any results.
            logger.error("HealthKit is not available. SpeziHealthKit and its module will still exist in the application, but all HealthKit-related functionality will be disabled.")
        }
        healthStore = HKHealthStore()
        pendingConfiguration = config()
        healthKitDataAccessRequirements = pendingConfiguration.reduce(.init()) { dataReqs, component in
            dataReqs.merging(with: component.dataAccessRequirements)
        }
    }
    
    
    /// Creates a new instance of the ``HealthKit`` module, with an empty configuration.
    public convenience init() {
        self.init { /* intentionally empty config */ }
    }


    /// Configures the HealthKit module.
    public func configure() {
        for component in pendingConfiguration {
            component.configure(for: self, on: standard)
        }
    }
    
    
    // MARK: HealthKit authorization handling

    /// Displays the user interface to ask for authorization for all HealthKit data defined by the ``HealthKitDataSourceDescription``s.
    ///
    /// Call this function when you want to start HealthKit data collection.
    @MainActor // TODO why is this MainActor-constrained? so that we can call it from SwiftUI?
    public func askForAuthorization() async throws {
        try await healthStore.requestAuthorization(
            toShare: healthKitDataAccessRequirements.write,
            read: healthKitDataAccessRequirements.read
        )
        didRequestAuthorization = true
        for dataSource in registeredDataSources {
            // TODO should this only call -askedForAuthorization on those data sources where the data source's accessed object types is a subset of what we've just asked for?
            await dataSource.askedForAuthorization()
        }
    }
    
    
    /// Returns whether the user was already asked for authorization to access the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    public func askedForAuthorization(forReading objectType: HKObjectType) -> Bool {
        healthKitDataAccessRequirements.read.contains(objectType)
    }
    
    /// Returns whether the user was already asked for authorization to access the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    public func askedForAuthorization(forWriting sampleType: HKSampleType) -> Bool {
        healthKitDataAccessRequirements.write.contains(sampleType)
    }
    
    
    // MARK: HealthKit data collection
    
    /// Adds a new data source for collecting health data in the background.
    @MainActor
    func addBackgroundHealthDataSource(_ dataSource: some HealthKitDataSource) {
        registeredDataSources.append(dataSource)
        Task {
            await dataSource.startAutomaticDataCollection()
        }
    }
    
    /// Triggers any ``HealthKitDeliverySetting/manual(saveAnchor:)`` collections and starts the collection for all ``HealthKitDeliveryStartSetting/manual`` HealthKit data collections.
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
    // TODO remove?!
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
