//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import OSLog
import Spezi


extension HKHealthStore {
    private static var activeObservations: [HKObjectType: Int] = [:]
    private static let activeObservationsLock = NSLock()
    
    
    func startBackgroundDelivery(
        for sampleTypes: Set<HKSampleType>,
        withPredicate predicate: NSPredicate? = nil
    ) async throws -> AsyncThrowingStream<(sampleTypes: Set<HKSampleType>, observerQueryCompletionHandler: HKObserverQueryCompletionHandler), Error> {
        try await enableBackgroundDelivery(for: sampleTypes)
        
        return AsyncThrowingStream { continuation in
            var queryDescriptors: [HKQueryDescriptor] = []
            for sampleType in sampleTypes {
                queryDescriptors.append(
                    HKQueryDescriptor(sampleType: sampleType, predicate: predicate)
                )
            }
            
            let observerQuery = HKObserverQuery(queryDescriptors: queryDescriptors) { query, samples, completionHandler, error in
                guard error == nil,
                      let samples else {
                    Logger.healthKit.error("Failed HealthKit background delivery for observer query \(query) with error: \(error)")
                    continuation.finish(throwing: error)
                    completionHandler()
                    return
                }
                
                continuation.yield((samples, completionHandler))
            }
            
            self.execute(observerQuery)
            
            continuation.onTermination = { @Sendable _ in
                self.stop(observerQuery)
                self.disableBackgroundDelivery(for: sampleTypes)
            }
        }
    }
    
    
    private func enableBackgroundDelivery(
        for objectTypes: Set<HKObjectType>,
        frequency: HKUpdateFrequency = .immediate
    ) async throws {
        try await self.requestAuthorization(toShare: [], read: objectTypes as Set<HKObjectType>)
        
        var enabledObjectTypes: Set<HKObjectType> = []
        do {
            for objectType in objectTypes {
                try await self.enableBackgroundDelivery(for: objectType, frequency: frequency)
                enabledObjectTypes.insert(objectType)
                Self.activeObservationsLock.withLock {
                    HKHealthStore.activeObservations[objectType] = HKHealthStore.activeObservations[objectType, default: 0] + 1
                }
            }
        } catch {
            Logger.healthKit.error("Could not enable HealthKit Backgound access for \(objectTypes): \(error.localizedDescription)")
            // Revert all changes as enable background delivery for the object types failed.
            disableBackgroundDelivery(for: enabledObjectTypes)
        }
    }
    
    
    private func disableBackgroundDelivery(
        for objectTypes: Set<HKObjectType>
    ) {
        for objectType in objectTypes {
            Self.activeObservationsLock.withLock {
                if let activeObservation = HKHealthStore.activeObservations[objectType] {
                    let newActiveObservation = activeObservation - 1
                    if newActiveObservation <= 0 {
                        HKHealthStore.activeObservations[objectType] = nil
                        Task { @MainActor in
                            try await self.disableBackgroundDelivery(for: objectType)
                        }
                    } else {
                        HKHealthStore.activeObservations[objectType] = newActiveObservation
                    }
                }
            }
        }
    }
}
