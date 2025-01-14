//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import OSLog
import Spezi
import SwiftUI


final class HealthKitSampleDataSource: HealthKitDataSource {
    // This needs to be unowned since the HealthKit module will establish a strong reference to the data source.
    private unowned let healthKit: HealthKit
    private let standard: any HealthKitConstraint
    
    private let sampleType: HKSampleType
    private let predicate: NSPredicate?
    private let deliverySetting: HealthKitDeliverySetting
    @MainActor private var active = false
    
    @MainActor private lazy var anchorUserDefaultsKey = UserDefaults.Keys.healthKitAnchorPrefix.appending(sampleType.identifier)
    @MainActor private lazy var anchor: HKQueryAnchor? = loadAnchor() {
        didSet {
            saveAnchor()
        }
    }
    
    private var healthStore: HKHealthStore { healthKit.healthStore }
    

    required init(
        healthKit: HealthKit,
        standard: any HealthKitConstraint,
        sampleType: HKSampleType,
        predicate: NSPredicate? = nil, // swiftlint:disable:this function_default_parameter_at_end
        deliverySetting: HealthKitDeliverySetting
    ) {
        self.healthKit = healthKit
        self.standard = standard
        self.sampleType = sampleType
        self.deliverySetting = deliverySetting

        if let predicate {
            self.predicate = predicate
        } else {
            self.predicate = HKQuery.predicateForSamples(
                withStart: HealthKitSampleDataSource.loadDefaultQueryDate(for: sampleType),
                end: nil,
                options: .strictEndDate
            )
        }
    }
    
    
    private static func loadDefaultQueryDate(for sampleType: HKSampleType) -> Date {
        let defaultPredicateDateUserDefaultsKey = UserDefaults.Keys.healthKitDefaultPredicateDatePrefix.appending(sampleType.identifier)
        guard let date = UserDefaults.standard.object(forKey: defaultPredicateDateUserDefaultsKey) as? Date else {
            // We start date collection at the previous full minute mark to make the
            // data collection deterministic to manually entered data in HealthKit.
            var components = Calendar.current.dateComponents(in: .current, from: .now)
            components.setValue(0, for: .second)
            components.setValue(0, for: .nanosecond)
            let defaultQueryDate = components.date ?? .now
            UserDefaults.standard.set(defaultQueryDate, forKey: defaultPredicateDateUserDefaultsKey)
            return defaultQueryDate
        }
        return date
    }
    

    func askedForAuthorization() async {
        guard healthKit.askedForAuthorization(forReading: sampleType) && !deliverySetting.isManual && !active else {
            return
        }
        await triggerManualDataSourceCollection()
    }
    
    
    func startAutomaticDataCollection() async {
        guard healthKit.askedForAuthorization(forReading: sampleType) else {
            return
        }
        switch deliverySetting {
        case .anchorQuery(.automatic, _), .background(.automatic, _):
            await triggerManualDataSourceCollection()
        default:
            break
        }
    }

    func triggerManualDataSourceCollection() async {
        guard !active else {
            return
        }
        do {
            switch deliverySetting {
            case .manual:
                try await anchoredSingleObjectQuery()
            case .anchorQuery:
                active = true
                try await anchoredContinuousObjectQuery()
            case .background:
                active = true
                try await healthStore.startBackgroundDelivery(for: [sampleType]) { result in
                    guard case let .success((sampleTypes, completionHandler)) = result else {
                        return
                    }
                    guard sampleTypes.contains(self.sampleType) else {
                        Logger.healthKit.warning("Received Observation query types (\(sampleTypes)) are not corresponding to the CollectSample type \(self.sampleType)")
                        completionHandler()
                        return
                    }
                    do {
                        try await self.anchoredSingleObjectQuery()
                        Logger.healthKit.debug("Successfully processed background update for \(self.sampleType)")
                    } catch {
                        Logger.healthKit.error("Could not query samples in a background update for \(self.sampleType): \(error)")
                    }

                    // Provide feedback to HealthKit that the data has been processed: https://developer.apple.com/documentation/healthkit/hkobserverquerycompletionhandler
                    completionHandler()
                }
            }
        } catch {
            Logger.healthKit.error("Could not Process HealthKit data collection: \(error.localizedDescription)")
        }
    }


    @MainActor
    private func anchoredSingleObjectQuery() async throws {
        let resultsAnchor = try await healthStore.anchoredSingleObjectQuery(
            for: self.sampleType,
            using: self.anchor,
            withPredicate: predicate,
            standard: self.standard
        )
        self.anchor = resultsAnchor
    }

    
    @MainActor
    private func anchoredContinuousObjectQuery() async throws {
        try await healthStore.requestAuthorization(toShare: [], read: [sampleType])
        let anchorDescriptor = healthStore.anchorDescriptor(sampleType: sampleType, predicate: predicate, anchor: anchor)
        let updateQueue = anchorDescriptor.results(for: healthStore)
        Task {
            for try await results in updateQueue {
                for deletedObject in results.deletedObjects {
                    await standard.remove(sample: deletedObject)
                }
                
                for addedSample in results.addedSamples {
                    await standard.add(sample: addedSample)
                }
                self.anchor = results.newAnchor
            }
        }
    }

    
    @MainActor
    private func saveAnchor() {
        if deliverySetting.saveAnchor {
            guard let anchor,
                  let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) else {
                return
            }
            UserDefaults.standard.set(data, forKey: anchorUserDefaultsKey)
        }
    }

    
    @MainActor
    private func loadAnchor() -> HKQueryAnchor? {
        guard deliverySetting.saveAnchor,
              let userDefaultsData = UserDefaults.standard.data(forKey: anchorUserDefaultsKey),
              let loadedAnchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: userDefaultsData) else {
            return nil
        }
        return loadedAnchor
    }
}
