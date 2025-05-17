//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension HealthChartDrawingConfig {
    @available(*, deprecated, renamed: "ChartType")
    public typealias Mode = ChartType
    
    @available(*, deprecated, renamed: "init(chartType:color:)")
    public init(mode: ChartType, color: Color) {
        self.init(chartType: mode, color: color)
    }
}
