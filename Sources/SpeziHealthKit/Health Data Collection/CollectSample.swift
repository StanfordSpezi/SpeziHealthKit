//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


/// Collects a specified ``SampleType``  via the ``HealthKit-class`` module.
///
/// This structure enables real-time Health data collection using the ``HealthKit-swift.class`` module, and allows defining when and how the collection should take place.
/// By default, all new samples of the provided ``SampleType`` will be collected; you an optionally provide a filter predicate.
///
/// Sample collection, unless specified otherwise, is started automatically (i.e., once the ``HealthKit-swift.class`` module has requested read access to the queried sample type).
/// This can be configured, allowing an app to delay starting of the sample collection until a moment of its choosing.
///
/// Sample collection optionally can be configured to continue in the background, i.e. even when the app is closed.
/// This is turned off by default, and can be enabled using the `continueInBackground` parameter.
///
/// Your app can optionally specify a ``CollectSample/TimeRange``, to control how far back the sample collection should go.
/// By default, ``CollectSample`` will use an open-ended time range starting at the point in time ``CollectSample`` was first registered for this specific sample type.
///
/// Your app can specify an `NSPredicate` to filter which samples should be collected.
/// For example, you could use this to limit your app's collection to only those samples whose values fall into a certain range,
/// or only those with a specific metadata key present.
public struct CollectSample<Sample: _HKSampleWithSampleType>: HealthKitConfigurationComponent {
    /// The time range for which new and deleted HealthKit samples should be collected.
    public enum TimeRange {
        /// Sample collection should cover all new samples, i.e., at the point in time the ``CollectSample`` instance is first registered with the ``HealthKit-swift.class`` module.
        ///
        /// The ``HealthKit-swift.class`` module maintains an internal record keeping track of the first time each ``SampleType`` was registered for collection using the ``CollectSample`` API.
        /// As a result, all subsequent app launches will be notified about any sample changes since the last launch, and so on.
        case newSamples
        /// Sample collection should start at the specified `Date`.
        case startingAt(Date)
    }
    private let sampleType: SampleType<Sample>
    private let deliverySetting: HealthDataCollectorDeliverySetting
    private let timeRange: TimeRange
    private let predicate: NSPredicate?
    
    public var dataAccessRequirements: HealthKit.DataAccessRequirements {
        .init(read: [sampleType])
    }
    
    /// Creates a `CollectSample` instance that collects health samples and delivers them to the app's standard.
    /// - Parameters:
    ///   - sampleType: The ``SampleType`` that should be collected
    ///   - start: How the sample collection should be started.
    ///   - continueInBackground: Whether the sample collection should continue in the background, i.e., even when the app is no longer running.
    ///   - timeRange: The time range for which samples should be collected. Defaults to a range collecting all new samples. Make sure to use an open-ended range here.
    ///   - predicate: A custom predicate that should be passed to the HealthKit query.
    ///                This predicate should **not** be used for time-based filtering; use the `timeRange` parameter for that.
    public init(
        _ sampleType: SampleType<Sample>,
        start: HealthDataCollectorDeliverySetting.Start = .automatic,
        continueInBackground: Bool = false,
        timeRange: TimeRange = .newSamples,
        predicate: NSPredicate? = nil
    ) {
        self.sampleType = sampleType
        self.deliverySetting = .init(startSetting: start, continueInBackground: continueInBackground)
        self.timeRange = timeRange
        self.predicate = predicate
    }
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) async {
        let timeRange: HealthKitQueryTimeRange = switch timeRange {
        case .newSamples:
            if let startDate = healthKit.sampleCollectionStartDates[sampleType] {
                .startingAt(startDate)
            } else {
                { () -> HealthKitQueryTimeRange in
                    let cal = Calendar.current
                    var components = cal.dateComponents(in: .current, from: .now)
                    components.setValue(0, for: .second)
                    components.setValue(0, for: .nanosecond)
                    let defaultQueryDate = cal.date(from: components) ?? .now
                    healthKit.sampleCollectionStartDates[sampleType] = defaultQueryDate
                    return .init(defaultQueryDate...)
                }()
            }
        case .startingAt(let date):
            .init(date...)
        }
        let collector = HealthKitSampleCollector(
            source: .collectSample,
            healthKit: healthKit,
            standard: standard,
            sampleType: sampleType,
            timeRange: timeRange,
            predicate: predicate,
            deliverySetting: deliverySetting
        )
        await healthKit.addHealthDataCollector(collector)
    }
}
