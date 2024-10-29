//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


public struct HealthChart: View {
    @State private var viewModel: ViewModel
    
    @State var disabledInteractions: HealthChartInteractions = []
    @State var chartStyle: HealthChartStyle = HealthChartStyle()
    
    
    public var body: some View {
        Text("here is the metric chart.")
    }
    
    
    public init(
        _ type: MeasurementType,
        in range: DateRange = .month(start: .now),
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self.viewModel = ViewModel(type: type, range: range, provider: provider)
    }
}
