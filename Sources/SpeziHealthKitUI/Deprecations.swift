//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import struct SwiftUI.Color

extension HealthChartDrawingConfig {
    @available(*, deprecated, renamed: "ChartType")
    public typealias Mode = ChartType // swiftlint:disable:this missing_docs
    
    @available(*, deprecated, renamed: "chartType")
    public var mode: ChartType { // swiftlint:disable:this missing_docs
        chartType
    }
    
    @available(*, deprecated, renamed: "init(chartType:color:)")
    public init(mode: ChartType, color: Color) { // swiftlint:disable:this missing_docs
        self.init(chartType: mode, color: color)
    }
}
