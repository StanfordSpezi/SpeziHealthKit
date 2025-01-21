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
/// Data collection is started by the `HealthKit` module, depending on the delivery setting and delivert start setting you specify:
/// | Delivery Setting | Delivery Start Setting | When does data collection take place |
/// |:-----:|:-----:|:---|
/// | `.manual` | n/a | Every call to ``HealthKit-swift.class/triggerDataSourceCollection()`` |
/// | `.continuous` or `.background` | `.automatic` |  the `HealthKit` module will start the collection as soon as possible, i.e. either directly when the app is launched (if the user has already been prompted to grant access to the collected sample type), or as soon as ``HealthKit-swift.class/askForAuthorization()`` was called by the app and the user dismissed the request authorization sheet. |
/// |^ | `.manual` | the first call to ``HealthKit-swift.class/triggerDataSourceCollection()`` will start the data collection |
///
/// Your specify an `NSPredicate` to filter which samples should be collected.
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
/// CollectSample(
///     .stepCount,
///     deliverySetting: .background(.automatic),
///     predicate: predicateOneMonth
/// )
/// ```
public struct CollectSample: HealthKitConfigurationComponent {
    private let sampleType: HKSampleType
    private let deliverySetting: HealthDataCollectorDeliverySetting
    private let predicate: NSPredicate?
    
    public var dataAccessRequirements: HealthKit.DataAccessRequirements {
        .init(read: [sampleType])
    }
    
    
    /// - Parameters:
    ///   - sampleType: The ``SampleType`` that should be collected
    ///   - predicate: A custom predicate that should be passed to the HealthKit query.
    ///                The default predicate collects all samples that have been collected from the first time that the user
    ///                provided the application authorization to collect the samples.
    ///   - delivery: The ``HealthDataCollectorDeliverySetting`` that should be used to collect the sample type. `.manual` is the default argument used.
    public init(
        _ sampleType: SampleType<some Any>,
        delivery: HealthDataCollectorDeliverySetting = .manual(),
        predicate: NSPredicate? = nil
    ) {
        self.sampleType = sampleType.hkSampleType
        self.deliverySetting = delivery
        self.predicate = predicate
    }
    
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) async {
        let collector = HealthKitSampleCollector(
            healthKit: healthKit,
            standard: standard,
            sampleType: sampleType,
            predicate: predicate,
            delivery: deliverySetting
        )
        await healthKit.addHealthDataCollector(collector)
    }
}
