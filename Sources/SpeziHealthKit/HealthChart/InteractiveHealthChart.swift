//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


extension HealthChart {
    public func makeInteractive(
        selection: Binding<HealthChartGranularity>,
        enabledGranularities: Set<HealthChartGranularity>// = Set(InteractiveHealthChart.Granularity.all)
    ) -> some View {
        // TODO QUESTION: what if $selection is not in enabledGranularities?!
        InteractiveHealthChart<repeat each Results>(
            interactivity: self.interactivity,
            granularity: selection,
            enabledGranularities: enabledGranularities,
            (repeat each entry)
        )
    }
}



public struct HealthChartGranularity: Hashable, Sendable {
    let timeRange: HealthKitQueryTimeRange
    let displayTitle: String
    
    public static let day = Self(timeRange: .today, displayTitle: "Day")
    public static let week = Self(timeRange: .lastNDays(7), displayTitle: "Week")
    public static let month = Self(timeRange: .lastNMonths(1), displayTitle: "Month")
    public static let quarter = Self(timeRange: .lastNMonths(3), displayTitle: "3M")
    public static let halfYear = Self(timeRange: .lastNMonths(6), displayTitle: "6M")
    public static let year = Self(timeRange: .lastNYears(1), displayTitle: "Year")
    public static let twoYears = Self(timeRange: .lastNYears(2), displayTitle: "2Y")
    public static let fiveYears = Self(timeRange: .lastNYears(5), displayTitle: "5Y")
    
    public static let all: [Self] = [
        .day, .week, .month, .quarter, .halfYear, .year, .twoYears, .fiveYears
    ]
}






struct InteractiveHealthChart<each Results: HealthKitQueryResults>: View {
    typealias Granularity = HealthChartGranularity
    
    private let interactivity: HealthChartInteractivity
    private let enabledGranularities: Set<Granularity>
    @Binding private var granularity: Granularity
    @State private var entry: (repeat HealthChartEntry<each Results>)
    
    
    fileprivate init(
        interactivity: HealthChartInteractivity,
        granularity: Binding<Granularity>,
        enabledGranularities: Set<Granularity>,
        _ entry: (repeat HealthChartEntry<each Results>)
    ) {
        self.interactivity = interactivity
        self.enabledGranularities = enabledGranularities
        self._granularity = granularity
        self._entry = .init(initialValue: (repeat each entry))
    }
    
    
    var body: some View {
        VStack {
            Picker("Time Range", selection: $granularity) {
                ForEach(Granularity.all.filter(enabledGranularities.contains), id: \.self) { granularity in
                    Text(granularity.displayTitle)
                }
            }
            .pickerStyle(.segmented)
            
            HealthChart(
                interactivity: interactivity,
                timeInterval: .range(granularity.timeRange.range)
            ) {
                (repeat each entry)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
//            LabeledContent("TimeRange", value: "\(granularity.timeRange.range)")
            LabeledContent("#DataPoints", value: { () -> String in
                var counts: [Int] = []
                for entry in repeat each entry {
                    guard !entry.isEmpty else {
                        continue
                    }
                    counts.append(entry.results.count)
                }
                return "\(counts.map(String.init).joined(separator: " + ")) = \(counts.reduce(0, +))"
            }())
        }
        .onChange(of: granularity) { old, new in
            precondition(old != new, "is same?")
            Task {
                entry = (repeat await (each entry).withTimeRange(new.timeRange))
            }
        }
    }
}
