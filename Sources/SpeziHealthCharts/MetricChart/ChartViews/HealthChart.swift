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
    @State private var viewModel: ViewModel
    
    @State var disabledInteractions: HealthChartInteractions = []
    @State var chartStyle: HealthChartStyle = HealthChartStyle()
    
    
    public var body: some View {
        Text("here is the metric chart.")
    }
    
    
    public init(
        _ type: HKQuantityType,
        in initialRange: ChartRange = .month,
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self.viewModel = ViewModel(type: type, range: initialRange, provider: provider)
    }
    
    // TODO: With a binding to range.
//    public init(
//        _ type: HKQuantityType,
//        range: Binding<ChartRange>,
//        provider: any DataProvider = HealthKitDataProvider()
//    ) {
//        
//    }
}
