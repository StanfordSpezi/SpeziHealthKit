//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A `DataPoint` contains all the necessary information to plot a single element in a Chart.
/// - Parameters:
///     - value: The value of the measured quantity, which determines the point's position on the y-axis.
///     - timestamp: The date corresponding to when the quantity was measured, which determines the point's position on the x-axis.
///     - type: The type of quantity that the measurement belongs to, which determines the point's membership in a `Series`.
public struct DataPoint: Identifiable, Hashable {
    public var id: Self { self }
    
    public let value: Double
    public let timestamp: Date
    public let type: String
}
