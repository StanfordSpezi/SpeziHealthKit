//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import SpeziViews


enum AsyncState<T: Sendable>: Sendable {
    case idle
    case processing
    case success(T)
    case failure(LocalizedError)
}


extension HealthChart {
    @Observable
    @MainActor
    class ViewModel {
        private let type: MeasurementType
        private let provider: any DataProvider
        
        private var _range: DateRange
        var range: DateRange {
            get {
                return _range
            }
            set {
                self._range = newValue
                self.refresh(using: self.provider, range: newValue)
            }
        }
        
        private let measurementCache = MeasurementCache()
        
        @ObservationIgnored
        private var fetchTask: Task<Void, Never>?
        
        private(set) var measurements: AsyncState<[DataPoint]> = .idle
        
        
        init(
            type: MeasurementType,
            range: DateRange,
            provider: any DataProvider
        ) {
            self.type = type
            self.provider = provider
            self._range = range
        }
        
        
        /// Replaces `ViewModel.measurements` with new data points provided by `provider`.
        ///
        /// Passes currently stored `ViewModel.dateRange` and `ViewModel.type` options to the `DataProvider.fetchData` method.
        private func refresh(using provider: any DataProvider, range dateRange: DateRange) {
            self.fetchTask?.cancel()
            
            self.fetchTask = Task { @MainActor in
                self.measurements = .processing
                
                do {
                    // First, try to fetch measurements from the cache.
                    if let cachedData = try? await self.measurementCache.fetch(for: self.type, range: dateRange.interval) {
                        self.measurements = .success(cachedData)
                        return
                    }
                    
                    // If nothing is found in the cache, query the data provider.
                    let newMeasurements = try await provider.fetchData(for: self.type, in: dateRange.interval)
                    
                    // Only set the changes if the task wasn't cancelled.
                    guard !Task.isCancelled else {
                        return
                    }
                    
                    self.measurements = .success(newMeasurements)
                    await self.measurementCache.store(newMeasurements, for: self.type, range: dateRange)
                    
                } catch {
                    self.measurements = .failure(
                        AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to fetch new measurements."
                        )
                    )
                }
            }
        }
    }
}
