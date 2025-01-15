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
    private var healthKitDataAccessRequirements: HealthKitDataAccessRequirements
    
    /// Configurations which were supplied to the initializer, but have not yet been applied.
    /// - Note: This property is intended only to store the configuration until `configure()` has been called. It is not used afterwards.
    @ObservationIgnored private var pendingConfiguration: [any HealthKitConfigurationComponent]
    
    /// All background-data-collecting data sources registered with the HealthKit module.
    @ObservationIgnored private var registeredDataSources: [any HealthKitDataSource] = [] // TODO different name? (property&protocol!)
    
    
    /// Creates a new instance of the ``HealthKit`` module.
    /// - parameter config: The configuration defines the behaviour of the `HealthKit` module,
    ///     specifying e.g. which samples the app wants to continuously collect (via ``CollectSample`` and ``CollectSamples``,
    ///     and which sample and object types the user should be prompted to grant the app read access to (via ``RequestReadAccess``).
    public init(
        @ArrayBuilder<any HealthKitConfigurationComponent> _ config: () -> [any HealthKitConfigurationComponent]
    ) {
        healthStore = HKHealthStore()
        pendingConfiguration = config()
        healthKitDataAccessRequirements = pendingConfiguration.reduce(.init()) { dataReqs, component in
            dataReqs.merging(with: component.dataAccessRequirements)
        }
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


    /// Configures the HealthKit module.
    public func configure() {
        Task {
            for component in exchange(&pendingConfiguration, with: []) {
                await component.configure(for: self, on: self.standard)
            }
        }
    }
    
    
    // MARK: HealthKit authorization handling

    /// Requests authorization for accessing all HealthKit data types defined in the ``HealthKit-swift.class`` module's current data access requirements list.
    /// Once the initial configuration of the ``HealthKit-swift.class`` module has completed, this list will consist of all data types defined by the individual configuration components,
    /// i.e., for example anything required by a ``CollectSample`` component, or explicitly requested via ``RequestReadAccess`` or ``RequestWriteAccess``.
    ///
    /// Calling this function will also activate all data collecting components from the module configuration (e.g., ``CollectSample``)
    /// which require read access to data types for which the user hadn't already be prompted in the past.
    /// If all necessary authorizations have already been requested (regardless of whether the user granted or denied access),
    /// this function will not present any UI to the user, but will still activate the configuration components.
    ///
    /// - Note: There is no need for an app itself to keep track of whether it already requested health data access; the ``HealthKit-swift.class`` takes care of this.
    ///
    /// - Important: You need to call this function at some point during your app's lifecycle, ideally soon after the app was launched.
    @MainActor
    public func askForAuthorization() async throws {
        try await askForAuthorization(for: healthKitDataAccessRequirements)
    }
    
    
    /// Requests authorization for read and/or write access to a specific set of `HealthKit` sample types.
    ///
    /// This function exists in addition to ``askForAuthorization()``, and allows an app to request additional health data access beyond the initial,
    /// access requirements (which are computed based on the ``HealthKit-swift.class`` module's configuration).
    ///
    /// If all necessary authorizations have already been requested (regardless of whether the user granted or denied access),
    /// this function will not present any UI to the user.
    ///
    /// - Note: There is no need for an app itself to keep track of whether it already requested health data access; the ``HealthKit-swift.class`` takes care of this.
    ///
    /// - Warning: Only request write access to HealthKit data if your app's `Info.plist` file
    ///     contains an entry for the `NSHealthUpdateUsageDescription` key.
    @MainActor
    public func askForAuthorization(for accessRequirements: HealthKitDataAccessRequirements) async throws {
        self.healthKitDataAccessRequirements.merge(with: accessRequirements)
        try await healthStore.requestAuthorization(
            toShare: accessRequirements.write,
            read: accessRequirements.read
        )
        for dataSource in registeredDataSources where !dataSource.isActive && accessRequirements.read.contains(dataSource.sampleType) {
            await dataSource.askedForAuthorization()
        }
    }
    
    
    /// Returns whether the user was already asked for authorization to access the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    @MainActor
    public func askedForAuthorization(forReading objectType: HKObjectType) async -> Bool {
        do {
            // status: whether the user would be presented with an authorization request sheet, were we to request access
            let status = try await healthStore.statusForAuthorizationRequest(toShare: [], read: [objectType])
            switch status {
            case .shouldRequest:
                // we should request access, meaning that it would show a sheet, meaning that we haven't yet asked.
                return false
            case .unknown:
                // Docs: "The authorization request status could not be determined because an error occurred."
                // Question here is whether this branch is actually reachable for us, sincce we're using the async version of the method
                // (which doesn't use a completionHandler which would be passed both an error and the enum.)
                // We interpret this as not having asked the user. (Same as how we handle the error branch below.)
                return false
            case .unnecessary:
                // we have already requested access.
                return true
            @unknown default:
                return false
            }
        } catch {
            // We interpret an error as not having asked the user
            return false
        }
    }
    
    /// Returns whether the user was already asked for authorization to  the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    public func askedForAuthorization(forWriting objectType: HKObjectType) -> Bool {
        switch healthStore.authorizationStatus(for: objectType) {
        case .notDetermined:
            false
        case .sharingAuthorized, .sharingDenied:
            true
        @unknown default:
            false // fallback. better be safe than sorry.
        }
    }
    
    
    // MARK: HealthKit data collection
    
    /// Adds a new data source for collecting health data in the background.
    @MainActor
    func addBackgroundHealthDataSource(_ dataSource: some HealthKitDataSource) async {
        registeredDataSources.append(dataSource)
        if await askedForAuthorization(forReading: dataSource.sampleType) {
            // If we already asked for authentication to this specific sample type, we can directly start it.
            // Otherwise, the next call to askForAuthorization will trigger the start of the data collection.
            Task {
                await dataSource.startAutomaticDataCollection()
            }
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
