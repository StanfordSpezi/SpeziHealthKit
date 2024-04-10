//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//
// Created by Bryant Jimenez and Matthew Joerke

import HealthKit
import OSLog
import Spezi
import SwiftUI

@Observable
final class BulkUploadSampleDataSource: HealthKitDataSource {
    let healthStore: HKHealthStore
    let standard: any BulkUploadConstraint
    
    let sampleType: HKSampleType
    let predicate: NSPredicate?
    let deliverySetting: HealthKitDeliverySetting
    let bulkSize: Int
    var active = false
    var totalSamples: Int = 0
    var processedSamples: Int = 0 {
        didSet {
            saveProcessedSamples()
        }
    }
    
    // lazy variables cannot be observable
    @ObservationIgnored private lazy var anchorUserDefaultsKey = UserDefaults.Keys.bulkUploadAnchorPrefix.appending(sampleType.identifier)
    @ObservationIgnored private lazy var totalSamplesKey = UserDefaults.Keys.bulkUploadTotalSamplesPrefix.appending(sampleType.identifier)
    @ObservationIgnored private lazy var processedSamplesKey = UserDefaults.Keys.bulkUploadProcessedSamplesPrefix.appending(sampleType.identifier)
    @ObservationIgnored private lazy var anchor: HKQueryAnchor? = loadAnchor() {
        didSet {
            saveAnchor()
        }
    }
    
    public var progress: Progress {
        let progress = Progress(totalUnitCount: Int64(totalSamples))
        progress.completedUnitCount = Int64(processedSamples)
        return progress
    }
    
    // We disable the SwiftLint as we order the parameters in a logical order and
    // therefore don't put the predicate at the end here.
    // swiftlint:disable function_default_parameter_at_end
    required init(
        healthStore: HKHealthStore,
        standard: any BulkUploadConstraint,
        sampleType: HKSampleType,
        predicate: NSPredicate,
        deliverySetting: HealthKitDeliverySetting,
        bulkSize: Int
    ) {
        self.healthStore = healthStore
        self.standard = standard
        self.sampleType = sampleType
        self.deliverySetting = deliverySetting
        self.bulkSize = bulkSize
        self.predicate = predicate
        
        loadTotalSamplesOnce()
        self.processedSamples = loadProcessedSamples()
    }
    // swiftlint:enable function_default_parameter_at_end
    
    func askedForAuthorization() async {
        guard askedForAuthorization(for: sampleType) && !deliverySetting.isManual && !active else {
            return
        }
        
        await triggerManualDataSourceCollection()
    }
    
    func startAutomaticDataCollection() async {
        guard askedForAuthorization(for: sampleType) else {
            return
        }
        
        switch deliverySetting {
        case let .anchorQuery(startSetting, _) where startSetting == .automatic:
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
            active = true
            try await anchoredBulkUploadQuery()
        } catch {
            Logger.healthKit.error("Could not Process HealthKit data collection: \(error.localizedDescription)")
        }
    }
    
    
    private func anchoredBulkUploadQuery() async throws {
        try await healthStore.requestAuthorization(toShare: [], read: [sampleType])
        
        // create an anchor descriptor that reads a data batch of the defined bulkSize
        var anchorDescriptor = HKAnchoredObjectQueryDescriptor(
            predicates: [
                .sample(type: sampleType, predicate: predicate)
            ],
            anchor: anchor,
            limit: bulkSize
        )
        
        // run query at least once
        var result = try await anchorDescriptor.result(for: healthStore)
        
        // continue reading bulkSize batches of data until theres no new data
        repeat {
            await standard.processBulk(samplesAdded: result.addedSamples, samplesDeleted: result.deletedObjects)
            self.processedSamples += result.addedSamples.count + result.deletedObjects.count
            
            // advance the anchor
            anchor = result.newAnchor
            
            anchorDescriptor = HKAnchoredObjectQueryDescriptor(
                predicates: [
                    .sample(type: sampleType, predicate: predicate)
                ],
                anchor: anchor,
                limit: bulkSize
            )
            result = try await anchorDescriptor.result(for: healthStore)
        } while (!result.addedSamples.isEmpty) || (!result.deletedObjects.isEmpty)
    }
    
    private func saveAnchor() {
        if deliverySetting.saveAnchor {
            guard let anchor,
                  let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) else {
                return
            }
            
            UserDefaults.standard.set(data, forKey: anchorUserDefaultsKey)
        }
    }
    
    private func loadAnchor() -> HKQueryAnchor? {
        guard deliverySetting.saveAnchor,
              let userDefaultsData = UserDefaults.standard.data(forKey: anchorUserDefaultsKey),
              let loadedAnchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: userDefaultsData) else {
            return nil
        }
        
        return loadedAnchor
    }
    
    private func loadTotalSamplesOnce() {
        let cachedTotal = UserDefaults.standard.integer(forKey: totalSamplesKey)
        if cachedTotal != 0 { // user defaults to 0 if key is missing
            self.totalSamples = cachedTotal
        } else {
            // Initial query to fetch the total count of samples
            _ = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit,
                                           sortDescriptors: nil) { (query, results, error) in
                guard let samples = results else {
                    print("Error computing total size of bulk upload: could not retrieve samples of current sample type")
                    return
                }
                UserDefaults.standard.set(samples.count, forKey: self.totalSamplesKey)
                self.totalSamples = samples.count
            }
        }
    }
    
    private func saveProcessedSamples() {
        UserDefaults.standard.set(processedSamples, forKey: processedSamplesKey)
    }
    
    private func loadProcessedSamples() -> Int {
        return UserDefaults.standard.integer(forKey: processedSamplesKey)
    }
}
