//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziHealthKit
import SwiftUI



// TODO implement or remove!
public struct HealthOverview<each Results: HealthKitQueryResults>: View {
    private let component: (repeat HealthOverviewComponent<each Results>)
    
    public init(_ component: repeat HealthOverviewComponent<each Results>) {
        self.component = (repeat each component)
    }
    
    public var body: some View {
        Text("coming soon ;)")
    }
}




public final class HealthOverviewComponent<Results: HealthKitQueryResults> {
//    public enum Config {
//        case mostRecentSample
//        case chart(HealthChartDrawingConfig)
//    }
    
    private enum Config {
        case mostRecentSample
        case chart(HealthChartDrawingConfig)
    }
    
    private let results: Results
    private let config: Config
    
    private init(results: Results, config: Config) {
        self.results = results
        self.config = config
    }
    
    public static func mostRecentValue(_ results: Results) -> Self where Results.Element == HKQuantitySample {
        Self.init(results: results, config: .mostRecentSample)
    }
    
    public static func chart(_ results: Results, config drawingConfig: HealthChartDrawingConfig) -> Self where Results.Element == HKStatistics {
        Self.init(results: results, config: .chart(drawingConfig))
    }
}

