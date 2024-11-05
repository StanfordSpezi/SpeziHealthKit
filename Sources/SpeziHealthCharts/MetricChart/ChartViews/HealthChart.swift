//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI
import HealthKit

// TODO: Next steps:
// Verify data flow / implement data input infrastructure.
// Mock text in `HealthChart` just shows the current values of all inputs.
// See how they change with picker, modifiers, etc.

public struct HealthChart: View {
    @State private var range: ChartRange
    @State private var rangeBinding: Binding<ChartRange>?
    @State private var measurements: [HKQuantitySample] = []
    
    private let quantityType: HKQuantityType
    private let dataProvider: any DataProvider
    
    
    public var body: some View {
        Text("here is the metric chart.")
            .onChange(of: range) { _, newRange in
                Task { @MainActor in
                    measurements = try await dataProvider.fetchData(for: quantityType, in: newRange)
                }
            }
    }
    
    
    public init(
        _ type: HKQuantityType,
        in initialRange: ChartRange = .month,
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self.quantityType = type
        self.range = initialRange
        self.dataProvider = provider
    }
    
    public init(
        _ type: HKQuantityType,
        range: Binding<ChartRange>,
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self.range = range.wrappedValue
        self.rangeBinding = range
        self.quantityType = type
        self.dataProvider = provider
    }
}
