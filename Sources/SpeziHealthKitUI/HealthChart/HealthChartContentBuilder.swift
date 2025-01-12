//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit


extension HealthKitQueryResults {
    fileprivate static func _makeEmptyHealthChartEntry() -> HealthChartEntry<Self> {
        HealthChartEntry.makeEmpty()
    }
}


/// The ``HealthChartContentBuilder`` builds up the content (which is a tuple of ``HealthChartEntry`` objects) of the chart.
@resultBuilder
public enum HealthChartContentBuilder {
    /// Intermediate representation of a variadic-length tuple of ``HealthChartEntry`` objects, used for building up the tuple.
    /// This exists to work around https://github.com/swiftlang/swift/issues/78392.
    public struct _Tuple<each Results: HealthKitQueryResults> {
        let entry: (repeat HealthChartEntry<each Results>)
        
        init(_ entry: (repeat HealthChartEntry<each Results>)) {
            self.entry = (repeat each entry)
        }
    }
    
    
    public static func buildExpression<Results>(_ entry: HealthChartEntry<Results>) -> _Tuple<Results> {
        .init((entry))
    }
    
    public static func buildExpression<each Results>(_ entry: (repeat HealthChartEntry<each Results>)) -> _Tuple<repeat each Results> {
        .init((repeat each entry))
    }
    
    public static func buildOptional<each Results>(
        _ tuple: HealthChartContentBuilder._Tuple<repeat each Results>?
    ) -> HealthChartContentBuilder._Tuple<repeat each Results> {
        if let tuple {
            tuple
        } else {
            // If we're passed a nil tuple, we instead construct a tuple of same length
            // (needed to keep the return type uniform across both branches), but filled with
            // "empty" entries.
            _Tuple<repeat each Results>((repeat (each Results)._makeEmptyHealthChartEntry()))
        }
    }
    
    public static func buildEither<each Results>(
        first tuple: _Tuple<repeat each Results>
    ) -> _Tuple<repeat each Results> {
        tuple
    }
    
    public static func buildEither<each Results>(
        second tuple: _Tuple<repeat each Results>
    ) -> _Tuple<repeat each Results> {
        tuple
    }
    
    public static func buildPartialBlock<each Results>(
        first tuple: _Tuple<repeat each Results>
    ) -> _Tuple<repeat each Results> {
        tuple
    }
    
    public static func buildPartialBlock<each Results, each NextResults>(
        accumulated: (_Tuple<repeat each Results>),
        next: _Tuple<repeat each NextResults>
    ) -> (_Tuple<repeat each Results, repeat each NextResults>) {
        .init((repeat each accumulated.entry, repeat each next.entry))
    }
    
    public static func buildBlock() -> _Tuple<> {
        .init(())
    }
    
    public static func buildFinalResult<each Results>(
        _ tuple: (_Tuple<repeat each Results>)
    ) -> (repeat HealthChartEntry<each Results>) {
        tuple.entry
    }
}
