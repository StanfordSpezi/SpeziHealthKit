//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
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
        private let type: HKQuantityType
        private let provider: any DataProvider
        
        private var _range: ChartRange
        private var _rangeBinding: Binding<ChartRange>?
        
        var range: ChartRange {
            get {
                return _rangeBinding?.wrappedValue ?? _range
            }
            set {
                self._range = newValue
                self.refreshMeasurements()
            }
        }
        
        private(set) var measurements: [HKQuantitySample] = []
        
        
        /// Queries the stored `DataProvider` to store all the data points that lie in the given `ChartRange` in the `.measurements` property.
        ///
        /// Internally, the `DataProvider` should only query the data store once (for all the measurements of that type), then cache the results. This
        /// call will then return the measurements in the cached array that lie in the new date range.
        private func refreshMeasurements() {
            
        }
        
        
        init(
            type: HKQuantityType,
            range: ChartRange,
            provider: any DataProvider
        ) {
            self.type = type
            self.provider = provider
            self._range = range
        }
        
        init(
            type: HKQuantityType,
            range: Binding<ChartRange>,
            provider: any DataProvider
        ) {
            
        }
    }
}
