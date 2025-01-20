//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


extension KeyValuePairs {
    /// Creates a `KeyValuePairs` object, using the elements of a `Sequence`.
    /// - parameter seq: The Sequence whose key-value pairs should be used as the values of the `KeyValuePairs` instance.
    @inlinable public init<S: Sequence>(_ seq: S) where S.Element == (Key, Value) {
        let initFn = unsafeBitCast(Self.init(dictionaryLiteral:), to: (([S.Element]) -> Self).self)
        self = initFn(Array(seq))
    }
}


struct SomeChartContent<Body: ChartContent>: ChartContent {
    private let content: () -> Body
    
    init(@ChartContentBuilder _ content: @escaping () -> Body) {
        self.content = content
    }
    
    var body: some ChartContent {
        content()
    }
}



extension ClosedRange where Bound == Date {
    /// The middle value of the range.
    var middle: Date {
        let diff = upperBound.timeIntervalSinceReferenceDate - lowerBound.timeIntervalSinceReferenceDate
        return Date(timeIntervalSinceReferenceDate: lowerBound.timeIntervalSinceReferenceDate + (diff / 2))
    }
}



extension View {
    /// Applies the receiver view to the specified closure.
    ///
    /// The purpose of this function is to serve as a utility for e.g. conditionally applying view modifiers:
    /// ```swift
    /// @State private var enableSelection: Bool
    ///
    /// var body: some View {
    ///     Chart { /* ... */ }
    ///         .transforming { view in
    ///             if enableSelection {
    ///                 view.chartXSelection(value: $xSelection)
    ///             } else {
    ///                 view
    ///         }
    /// }
    /// ```
    func transforming(@ViewBuilder _ transform: (Self) -> some View) -> some View {
        transform(self)
    }
}


enum TimeConstants {
    static let minute: TimeInterval = 60
    static let hour = 60 * minute
    static let day = 24 * hour
    static let week = 7 * day
    static let month = 31 * day
    static let year = 365 * day
}
