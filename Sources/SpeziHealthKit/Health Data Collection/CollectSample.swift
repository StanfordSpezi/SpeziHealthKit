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
/// This structure define what and how the ``HealthKit-class`` samples are collected.
/// By default, all samples of the provided ``SampleType`` will be collected; you an optionally provide a filter predicate.
///
/// Sample collection, by default is started automatically (i.e., once the ``HealthKit-swift.class`` module has requested read access to the queried sample type).
/// This can be configured, allowing an app to delay starting of the sample collection until a moment of its choosing.
///
/// Sample collection optionally can be configured to continue in the background, i.e. even when the app is closed.
/// This is turned off by default, and can be enabled using the `continueInBackground` parameter.
///
/// Your can specify an `NSPredicate` to filter which samples should be collected.
/// For example, you can define a predicate to only collect the data collected at a time within the given start and end date.
/// Below is an example to create a `NSPredicate` restricting the data collected in the previous month.
/// ```swift
/// private var predicateOneMonth: NSPredicate {
///     // Define the start and end time for the predicate. In this example,
///     // we want to collect the samples in the previous month.
///     let calendar = Calendar(identifier: .gregorian)
///     let today = calendar.startOfDay(for: Date())
///     // We want the end date to be tomorrow so that we can collect all the samples today.
///     guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
///         fatalError("*** Unable to calculate the end time ***")
///     }
///     // Define the start date to one month before.
///     guard let startDate = calendar.date(byAdding: .month, value: -1, to: today) else {
///         fatalError("*** Unable to calculate the start time ***")
///     }
///     // Initialize the NSPredicate with our start and end dates.
///     return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
/// }
/// ```
///
/// Then, you just need to configure `predicate` with the  `predicateOneMonth` you defined as above during your initialization of ``CollectSample`` to only collect data samples in the previous month.
///
/// ```swift
/// CollectSample(.stepCount, predicate: predicateOneMonth)
/// ```
public struct CollectSample<Sample: _HKSampleWithSampleType>: HealthKitConfigurationComponent {
    private let sampleType: SampleType<Sample>
    private let deliverySetting: HealthDataCollectorDeliverySetting
    private let predicate: NSPredicate?
    
    public var dataAccessRequirements: HealthKit.DataAccessRequirements {
        .init(read: [sampleType.hkSampleType])
    }
    
    
    /// Creates a `CollectSample` instance that collects health samples and delivers them to the app's standard.
    /// - Parameters:
    ///   - sampleType: The ``SampleType`` that should be collected
    ///   - start: How the sample collection should be started.
    ///   - continueInBackground: Whether the sample collection should continue in the background, i.e., even when the app is no longer running.
    ///   - predicate: A custom predicate that should be passed to the HealthKit query.
    ///                The default predicate collects all samples that have been collected from the first time that the user
    ///                provided the application authorization to collect the samples.
    public init(
        _ sampleType: SampleType<Sample>,
        start: HealthDataCollectorDeliverySetting.Start = .automatic,
        continueInBackground: Bool = false,
        predicate: NSPredicate? = nil
    ) {
        self.sampleType = sampleType
        self.deliverySetting = .init(startSetting: start, continueInBackground: continueInBackground)
        self.predicate = predicate
    }
    
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) async {
        let collector = HealthKitSampleCollector(
            healthKit: healthKit,
            standard: standard,
            sampleType: sampleType,
            predicate: predicate,
            deliverySetting: deliverySetting
        )
        await healthKit.addHealthDataCollector(collector)
    }
}
