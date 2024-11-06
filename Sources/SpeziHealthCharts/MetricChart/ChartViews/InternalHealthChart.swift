//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct InternalHealthChart: View {
    @Binding private var range: ChartRange
    @State private var measurements: [Int] = [1]
    
    
    @Environment(\.disabledChartInteractions) private var disabledInteractions
    @Environment(\.healthChartStyle) private var chartStyle
    
    
    private let quantityType: HKQuantityType
    private let dataProvider: any DataProvider
    
    
    var body: some View {
        List {
            HStack {
                Text("Quantity Type:")
                    .bold()
                Spacer(minLength: 5)
                Text(quantityType.identifier)
            }
            HStack {
                Text("Chart Range (Binding):")
                    .bold()
                Spacer(minLength: 5)
                Text(range.interval.description)
            }
            HStack {
                Text("Chart Style (Modifier):")
                    .bold()
                Spacer(minLength: 5)
                Text("\(chartStyle.frameSize)")
            }
            HStack {
                Text("Disabled Interactions (Modifier):")
                    .bold()
                Spacer(minLength: 5)
                Text(String(disabledInteractions.rawValue, radix: 2))
            }
            Section("Measurements") {
                ForEach(measurements, id: \.self) { measurement in
                    Text("\(measurement)")
                }
            }
        }
            .onChange(of: range) { _, _ in
                measurements.append(measurements.reduce(0, +))
            }
    }
    
    
    init(
        _ type: HKQuantityType,
        range: Binding<ChartRange>,
        provider: any DataProvider = HealthKitDataProvider()
    ) {
        self._range = range
        self.quantityType = type
        self.dataProvider = provider
    }
}
