//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length

import HealthKit
import OSLog
import Spezi
import SpeziFoundation
import SpeziLocalStorage
import SwiftUI


/// Spezi Module for interacting with the HealthKit system.
///
/// See <doc:ModuleConfiguration> for a detailed introduction.
///
/// ## Topics
///
/// ### Initializing the HealthKit Module
/// - ``init()``
/// - ``init(_:)``
///
/// ### Instance Properties
/// - ``healthStore``
/// - ``configurationState``
/// - ``ConfigState``
///
/// ### Registering Data Collectors
/// - ``addHealthDataCollector(_:)-1sq79``
/// - ``addHealthDataCollector(_:)-10bp6``
/// - ``triggerDataSourceCollection()``
/// - ``resetSampleCollection(for:)``
///
/// ### Fetching Health Data
/// - ``query(_:timeRange:limit:sortedBy:predicate:)``
/// - ``query(_:timeRange:anchor:limit:predicate:)``
/// - ``oldestSampleDate(for:)``
/// - ``continuousQuery(_:timeRange:anchor:limit:predicate:)-66r9v``
/// - ``ContinuousQueryElement``
///
/// ### Handling Authorization
/// - ``dataAccessRequirements-swift.property``
/// - ``isFullyAuthorized``
/// - ``askForAuthorization()``
/// - ``askForAuthorization(for:)``
/// - ``isAuthorized(toWrite:)-4a3vx``
/// - ``isAuthorized(toWrite:)-1v3ch``
/// - ``didAskForAuthorization(for:)``
/// - ``didAskForAuthorization(toRead:)-7jia9``
/// - ``didAskForAuthorization(toRead:)-5343t``
/// - ``didAskForAuthorization(toRead:)-179xf``
/// - ``didAskForAuthorization(toRead:)-14mhe``
/// - ``didAskForAuthorization(toWrite:)-1q0oz``
/// - ``didAskForAuthorization(toWrite:)-3rlz6``
///
/// ## See Also
/// - <doc:ModuleConfiguration>
@Observable
public final class HealthKit: Module, EnvironmentAccessible, DefaultInitializable, @unchecked Sendable {
    /// The state of the HealthKit module's initial configuration operation.
    public enum ConfigState: Hashable, Sendable {
        /// The module has yet to perform its initial configuration
        case pending
        /// The module is currently performing its initial configuration
        case ongoing
        /// The module has completes its initial configuration
        case completed
    }
    
    private struct AuthorizationEventObserver {
        let accessRequirements: DataAccessRequirements
        let continuation: AsyncStream<DataAccessRequirements>.Continuation
    }
    
    @ObservationIgnored @StandardActor
    private var standard: any HealthKitConstraint
    
    @ObservationIgnored @Application(\.logger)
    var logger
    
    @ObservationIgnored @Dependency(LocalStorage.self)
    private var localStorage
    
    /// The HealthKit module's underlying `HKHealthStore`.
    public let healthStore: HKHealthStore
    
    /// The data access requirements that resulted form the initial configuration passed to the ``HealthKit-swift.class`` module.
    @_spi(Testing)
    public let initialConfigDataAccessRequirements: DataAccessRequirements
    
    /// The HealthKit module's current access requirements, resulting from its initial configuration and subsequent authorizations.
    public private(set) var dataAccessRequirements: DataAccessRequirements = .init()
    
    /// Whether all of the module's current data access requirements were prompted to the user.
    ///
    /// - Note: The value of this property can change throughout the lifetime of the module;
    /// e.g. if additional data access requirements are introduced after a call to ``HealthKit-swift.class/askForAuthorization()``, it might transition from `true` back to `false`.
    ///
    /// - Note: This property being `true` does not imply that the user actually granted access to all sample types; it just means that the user was asked.
    public private(set) var isFullyAuthorized: Bool = false
    
    /// The state of the module's configuration, i.e. whether the initial configuration is still pending, currently ongoing, or already completed.
    @ObservationIgnored public private(set) var configurationState: ConfigState = .pending
    
    /// Configurations which were supplied to the initializer, but have not yet been applied.
    /// - Note: This property is intended only to store the configuration until `configure()` has been called. It is not used afterwards.
    @ObservationIgnored private var pendingConfiguration: [any HealthKitConfigurationComponent] = []
    
    /// All background-data-collecting data sources registered with the HealthKit module.
    @ObservationIgnored /* private-but-testable */ private(set) var registeredDataCollectors: [any HealthDataCollector] = []
    
    private var authorizationEventObservers: [UUID: AuthorizationEventObserver] = [:]
    
    
    /// Creates a new instance of the ``HealthKit-class`` module, with the specified configuration.
    /// - parameter config: The configuration defines the behaviour of the `HealthKit` module,
    ///     specifying e.g. which samples the app wants to continuously collect (via ``CollectSample``),
    ///     and which sample and object types the user should be prompted to grant the app read access to (via ``RequestReadAccess``).
    public init(
        @ArrayBuilder<any HealthKitConfigurationComponent> _ config: () -> [any HealthKitConfigurationComponent]
    ) {
        healthStore = HKHealthStore()
        pendingConfiguration = config()
        initialConfigDataAccessRequirements = pendingConfiguration.reduce(.init()) { dataReqs, component in
            dataReqs.merging(with: component.dataAccessRequirements)
        }
        dataAccessRequirements = initialConfigDataAccessRequirements
        if !HKHealthStore.isHealthDataAvailable() {
            // If HealthKit is not available, we still initialise the module and the health store as normal.
            // Queries and sample collection, in this case, will simply not return any results.
            Logger.healthKit.error(
                """
                HealthKit is not available.
                SpeziHealthKit and its module will still exist in the application, but all HealthKit-related functionality will be disabled.
                """
            )
        }
    }
    
    
    /// Creates a new instance of the ``HealthKit-class`` module, with an empty configuration.
    public convenience init() {
        self.init { /* intentionally empty config */ }
    }
    
    
    /// Configures the HealthKit module.
    @_documentation(visibility: internal)
    public func configure() {
        configurationState = .ongoing
        Task {
            for component in exchange(&pendingConfiguration, with: []) {
                await component.configure(for: self, on: self.standard)
            }
            await updateIsFullyAuthorized(for: dataAccessRequirements)
            configurationState = .completed
        }
    }
}


extension HealthKit {
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
        try await askForAuthorization(for: dataAccessRequirements)
    }
    
    
    /// Requests authorization for read and/or write access to a specific set of `HealthKit` sample types.
    ///
    /// This function exists in addition to ``askForAuthorization()``, and allows an app to request additional health data access beyond the initial,
    /// access requirements (which are computed based on the ``HealthKit-swift.class`` module's configuration).
    ///
    /// If all necessary authorizations have already been requested (regardless of whether the user granted or denied access),
    /// this function will not present any UI to the user.
    ///
    /// - Note: There is no need for an app itself to keep track of whether it already requested health data access; the ``HealthKit-swift.class``module takes care of this.
    ///
    /// - Warning: Only request read or write access to HealthKit data if your app's `Info.plist` file
    ///     contains an entry for `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` respectively.
    @MainActor
    public func askForAuthorization(for accessRequirements: DataAccessRequirements) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        do {
            let prevAuthStates = await authorizationRequestStates(for: accessRequirements)
            if !accessRequirements.isEmpty {
                self.dataAccessRequirements.merge(with: accessRequirements)
                try await healthStore.requestAuthorization(
                    toShare: accessRequirements.write,
                    read: accessRequirements.read
                )
            }
            for collector in registeredDataCollectors {
                await startAutomaticDataCollectionIfPossible(collector)
            }
            for observer in authorizationEventObservers.values {
                let overlap = observer.accessRequirements.intersection(accessRequirements)
                guard !overlap.isEmpty else {
                    continue
                }
                if overlap.read.contains(where: { dataAccessRequirements.read.contains($0) && prevAuthStates[$0] != .unnecessary })
                    || overlap.write.contains(where: { dataAccessRequirements.write.contains($0) && prevAuthStates[$0] != .unnecessary }) {
                    observer.continuation.yield(accessRequirements)
                }
            }
            await updateIsFullyAuthorized(for: accessRequirements)
        } catch {
            await updateIsFullyAuthorized(for: accessRequirements)
            throw error
        }
    }
    
    
    /// Returns whether the user was already asked for authorization to access the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    @MainActor
    public func didAskForAuthorization(toRead sampleType: SampleType<some Any>) async -> Bool {
        await didAskForAuthorization(toRead: [sampleType])
    }
    
    /// Returns whether the user was already asked for authorization to access the specified object type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    @MainActor
    public func didAskForAuthorization(toRead objectType: HKObjectType) async -> Bool {
        await didAskForAuthorization(toRead: [objectType])
    }
    
    /// Returns whether the user was already asked for authorization to access all of the specified object types.
    ///
    /// This will only return `true` if the user was asked for authorization for all of the specified object types.
    ///
    /// - parameter sampleTypes: The set of sample types the function should check for. Passing in an empty set will result in a `true` return value, since there's nothing to check for.
    ///
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    @MainActor
    public func didAskForAuthorization(toRead sampleTypes: [any AnySampleType]) async -> Bool {
        await didAskForAuthorization(toRead: sampleTypes.flatMapIntoSet {
            $0.effectiveSampleTypesForAuthentication.map { $0.hkSampleType }
        })
    }
    
    /// Returns whether the user was already asked for authorization to access all of the specified object types.
    ///
    /// This will only return `true` if the user was asked for authorization for all of the specified object types.
    ///
    /// - parameter objectTypes: The set of object types the function should check for. Passing in an empty set will result in a `true` return value, since there's nothing to check for.
    ///
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    @MainActor
    public func didAskForAuthorization(toRead objectTypes: Set<HKObjectType>) async -> Bool {
        guard !objectTypes.isEmpty else {
            return true
        }
        let objectTypes = objectTypes.flatMapIntoSet { $0.effectiveObjectTypesForAuthentication }
        do {
            // status: whether the user would be presented with an authorization request sheet, were we to request access
            let status = try await healthStore.statusForAuthorizationRequest(toShare: [], read: objectTypes)
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
    
    /// Returns whether the user was already asked for authorization to  the specified sample type.
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    ///     Use ``HealthKit-swift.class/isAuthorized(toWrite:)-4a3vx`` to check the current authorization status.
    public func didAskForAuthorization(toWrite sampleType: SampleType<some Any>) -> Bool {
        sampleType.effectiveSampleTypesForAuthentication.allSatisfy {
            didAskForAuthorization(toWrite: $0.hkSampleType)
        }
    }
    
    /// Returns whether the user was already asked for authorization to the specified object type.
    ///
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    ///     Use ``HealthKit-swift.class/isAuthorized(toWrite:)-1v3ch`` to check the current authorization status.
    public func didAskForAuthorization(toWrite objectType: HKObjectType) -> Bool {
        switch healthStore.authorizationStatus(for: objectType) {
        case .notDetermined:
            false
        case .sharingAuthorized, .sharingDenied:
            true
        @unknown default:
            false // fallback. better be safe than sorry.
        }
    }
    
    /// Returns whether the user was already asked for authorization to access all of the specified object types.
    ///
    /// This will only return `true` if the user was asked for authorization for all of the specified object types.
    ///
    /// - parameter dataAccessRequirements: The set of object types the function should check for. Passing in an empty set will result in a `true` return value, since there's nothing to check for.
    ///
    /// - Note: A `true` return value does **not** imply that the user actually granted access; it just means that the user was asked.
    public func didAskForAuthorization(for dataAccessRequirements: DataAccessRequirements) async -> Bool {
        await didAskForAuthorization(toRead: dataAccessRequirements.read) && dataAccessRequirements.write.allSatisfy {
            didAskForAuthorization(toWrite: $0)
        }
    }
    
    
    /// Returns whether the application is currently authorized to write data of the specified object type into the health store..
    /// - Note: A `false` return value does **not** imply that the user actually denied access; it could also mean that the user hasn't yet been asked.
    ///     Use ``HealthKit-swift.class/didAskForAuthorization(toWrite:)-1q0oz`` to determine that.
    public func isAuthorized(toWrite sampleType: SampleType<some Any>) -> Bool {
        sampleType.effectiveSampleTypesForAuthentication.allSatisfy {
            isAuthorized(toWrite: $0.hkSampleType)
        }
    }
    
    /// Returns whether the application is currently authorized to write data of the specified object type into the health store..
    /// - Note: A `false` return value does **not** imply that the user actually denied access; it could also mean that the user hasn't yet been asked.
    ///     Use ``HealthKit-swift.class/didAskForAuthorization(toWrite:)-3rlz6`` to determine that.
    public func isAuthorized(toWrite objectType: HKObjectType) -> Bool {
        switch healthStore.authorizationStatus(for: objectType) {
        case .sharingAuthorized:
            true
        case .notDetermined, .sharingDenied:
            false
        @unknown default:
            false // fallback. better be safe than sorry.
        }
    }
    
    
    @MainActor
    private func updateIsFullyAuthorized(for dataAccessRequirements: DataAccessRequirements) async {
        guard !dataAccessRequirements.isEmpty else {
            return
        }
        if await !didAskForAuthorization(toRead: dataAccessRequirements.read) {
            isFullyAuthorized = false
        } else if !dataAccessRequirements.write.allSatisfy({ didAskForAuthorization(toWrite: $0) }) {
            isFullyAuthorized = false
        } else {
            isFullyAuthorized = true
        }
    }
    
    /// Monitor changes to the application's Health Data Authorizations
    ///
    /// Creates an `AsyncStream` that will emit an element every time health access authorizations are requested that overlap with the specified `accessRequirements`.
    ///
    /// - Note: For read requirements, the stream will emit an element regardless of whether or not the user actually granted access.
    @_spi(APISupport)
    @MainActor
    public func observeAuthenticationEvents(matching accessRequirements: DataAccessRequirements) -> AsyncStream<DataAccessRequirements> {
        let (stream, continuation) = AsyncStream.makeStream(of: DataAccessRequirements.self)
        let id = UUID()
        self.authorizationEventObservers[id] = .init(
            accessRequirements: accessRequirements,
            continuation: continuation
        )
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in
                self?.authorizationEventObservers[id] = nil
            }
        }
        return stream
    }
    
    private func authorizationRequestStates(for accessRequirements: DataAccessRequirements) async -> [HKObjectType: HKAuthorizationRequestStatus] {
        await withTaskGroup(
            of: (HKObjectType, HKAuthorizationRequestStatus).self,
            returning: [HKObjectType: HKAuthorizationRequestStatus].self
        ) { [healthStore] taskGroup in
            for writeTy in accessRequirements.write {
                taskGroup.addTask {
                    let status = try? await healthStore.statusForAuthorizationRequest(toShare: [writeTy], read: [writeTy])
                    return (writeTy, status ?? .unknown)
                }
            }
            for readTy in accessRequirements.read.subtracting(accessRequirements.write) {
                taskGroup.addTask {
                    let status = try? await healthStore.statusForAuthorizationRequest(toShare: [], read: [readTy])
                    return (readTy, status ?? .unknown)
                }
            }
            var retval: [HKObjectType: HKAuthorizationRequestStatus] = [:]
            for await (type, status) in taskGroup {
                retval[type] = status
            }
            return retval
        }
    }
}


extension HealthKit {
    // MARK: HealthKit data collection
    
    /// Provides access to the HealthKit module's query anchor storage system.
    var queryAnchors: SampleTypeScopedLocalStorage<QueryAnchor> {
        SampleTypeScopedLocalStorage(
            localStorage: localStorage,
            storageKeyPrefix: "edu.stanford.Spezi.SpeziHealthKit.queryAnchors",
            storageSetting: .unencrypted(excludeFromBackup: false)
        )
    }
    
    /// Keeps track of the first time a ``SampleType`` was registered for collection using ``CollectSample``.
    var sampleCollectionStartDates: SampleTypeScopedLocalStorage<Date> {
        SampleTypeScopedLocalStorage(
            localStorage: localStorage,
            storageKeyPrefix: "edu.stanford.Spezi.SpeziHealthKit.sampleCollectionStartDates",
            storageSetting: .unencrypted(excludeFromBackup: false)
        )
    }
    
    /// Resets the internal state associated with a sample type's collection via ``CollectSample``.
    ///
    /// Use this function if you want to reset ``CollectSample``, so that the next time a ``CollectSample`` instance is registered with the ``HealthKit-swift.class`` module,
    /// its behaviour will be as if it were being registered for the first time.
    ///
    /// - Note: Calling this function will stop currently-active sample collection for the specified `sampleType`.
    @MainActor
    public func resetSampleCollection<Sample>(for sampleType: SampleType<Sample>) async {
        defer {
            queryAnchors[sampleType] = nil
            sampleCollectionStartDates[sampleType] = nil
        }
        // we need to also stop the sample collector (and in fact we need to do so before resetting the query anchor and the start date),
        // since otherwise (were we to just reset the anchor and start date), the collection would continue to run and the next
        // query update would end up restoring the just-reset anchor.
        for (idx, collector) in registeredDataCollectors.enumerated().reversed() {
            guard let collector = collector as? HealthKitSampleCollector<Sample>,
                  collector.source == .collectSample,
                  collector.typeErasedSampleType == sampleType else {
                continue
            }
            await collector.stopDataCollection()
            registeredDataCollectors.remove(at: idx)
            return
        }
    }
    
    /// Adds a new ``CollectSample`` definition to the module.
    ///
    /// Calling this function is equivalent to including the ``CollectSample`` definition in the initial module configuration.
    @MainActor
    public func addHealthDataCollector(_ collectSample: CollectSample<some Any>) async {
        switch configurationState {
        case .pending:
            pendingConfiguration.append(collectSample)
        case .ongoing, .completed:
            dataAccessRequirements.merge(with: collectSample.dataAccessRequirements)
            await collectSample.configure(for: self, on: standard)
        }
    }
    
    /// Adds a new data source for collecting health data in the background.
    ///
    /// If the user was already asked for access to this collector's sample type, the collector will immediately be informed to
    /// start its automatic data collection.
    @MainActor
    public func addHealthDataCollector(_ newCollector: any HealthDataCollector) async {
        enum Action {
            case add
            case dontAdd
            case replace(index: Int)
        }
        let action: Action = { () -> Action in
            // Determine, based on the existing currently-registered collectors, how this one should be handled.
            for (idx, existingCollector) in self.registeredDataCollectors.enumerated() {
                guard existingCollector.typeErasedSampleType == newCollector.typeErasedSampleType else {
                    continue
                }
                if existingCollector.deliverySetting == newCollector.deliverySetting {
                    // the existing collector has the same sample type and delivery setting as the new one
                    // -> there's no need to add the new one (we already have an identical one)
                    return .dontAdd
                } else if existingCollector.deliverySetting.continueInBackground && !newCollector.deliverySetting.continueInBackground {
                    // we have an existing one which is supposed to run in the background, and a new one which is not.
                    // -> the background-enabled one can subsume the new one
                    return .dontAdd
                } else if !existingCollector.deliverySetting.continueInBackground && newCollector.deliverySetting.continueInBackground {
                    // the existing collector is supposed to only run while the app is active, while the new one should also
                    // continue in the background. we replace the existing one with the new one, thereby effectively subsuming it into the new one
                    return .replace(index: idx)
                }
            }
            // if none of the existing collectors matched against the new one (or if there weren't any existing ones),
            // we want to add the new one.
            return .add
        }()
        switch action {
        case .dontAdd:
            return
        case .replace(let index):
            let oldCollector = exchange(&registeredDataCollectors[index], with: newCollector)
            await oldCollector.stopDataCollection()
            await startAutomaticDataCollectionIfPossible(newCollector)
        case .add:
            registeredDataCollectors.append(newCollector)
            await startAutomaticDataCollectionIfPossible(newCollector)
        }
        await updateIsFullyAuthorized(for: dataAccessRequirements)
    }
    
    
    /// Tells the collector to start its automatic data collection, if applicable and possible.
    @MainActor
    private func startAutomaticDataCollectionIfPossible(_ collector: some HealthDataCollector) async {
        if !collector.isActive,
           collector.deliverySetting.startSetting == .automatic,
           await didAskForAuthorization(toRead: collector.sampleType) {
            await collector.startDataCollection()
        }
    }
    
    /// Triggers data collection for any currently registered ``HealthDataCollector``s that have a manual delivery setting.
    @MainActor
    public func triggerDataSourceCollection() async {
        await withTaskGroup(of: Void.self) { group in
            for collector in registeredDataCollectors where collector.deliverySetting.startSetting == .manual {
                group.addTask { @MainActor @Sendable in
                    await collector.startDataCollection()
                }
            }
            await group.waitForAll()
        }
    }
}


extension HealthKit.DataAccessRequirements {
    func overlaps(_ other: Self) -> Bool {
        !self.read.isDisjoint(with: other.read) || !self.write.isDisjoint(with: other.write)
    }
    
    func intersection(_ other: Self) -> Self {
        Self(
            read: read.intersection(other.read),
            write: write.intersection(other.write)
        )
    }
}


// MARK: Utilities

extension HKUnit {
    /// Creates a unit as the composition of dividing a unit by another unit.
    @inlinable public static func / (lhs: HKUnit, rhs: HKUnit) -> HKUnit {
        lhs.unitDivided(by: rhs)
    }
    
    /// Creates a unit as the composition of multiplying a unit with another unit.
    @inlinable public static func * (lhs: HKUnit, rhs: HKUnit) -> HKUnit {
        lhs.unitMultiplied(by: rhs)
    }
}
