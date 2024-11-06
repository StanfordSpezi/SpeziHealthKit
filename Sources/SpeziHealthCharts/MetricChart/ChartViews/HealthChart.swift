//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import HealthKit


public struct HealthChart: View {
    @State private var privateRange: ChartRange
    private var privateRangeBinding: Binding<ChartRange>?
    
    var range: Binding<ChartRange> {
        Binding(
            get: {
                privateRangeBinding?.wrappedValue ?? privateRange
            }, set: { newValue in
                if let privateRangeBinding {
                    privateRangeBinding.wrappedValue = newValue
                } else {
                    privateRange = newValue
                }
            }
        )
    }
    
    private let quantityType: HKQuantityType
    private let dataProvider: any DataProvider
    
    
    public var body: some View {
        InternalHealthChart(quantityType, range: range, provider: dataProvider)
    }
    
    
    public init(
        _ type: HKQuantityType,
        in initialRange: ChartRange = .month,
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self.quantityType = type
        self.privateRange = initialRange
        self.dataProvider = provider
    }
    
    public init(
        _ type: HKQuantityType,
        range: Binding<ChartRange>,
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self.privateRange = range.wrappedValue
        self.privateRangeBinding = range
        self.quantityType = type
        self.dataProvider = provider
    }
}
