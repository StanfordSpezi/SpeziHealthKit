//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// The ``HealthChartContentBuilder`` builds up the content (which is a tuple of ``HealthChartEntry`` objects) of the chart.
@resultBuilder
public enum HealthChartContentBuilder {
    /// Intermediate representation of a variadic-length tuple of ``HealthChartEntry`` objects, used for building up the tuple.
    /// This exists to work around https://github.com/swiftlang/swift/issues/78392.
    public struct _Tuple<each Results: HealthKitQueryResults> { // swiftlint:disable:this type_name
        @usableFromInline let entry: (repeat HealthChartEntry<each Results>)
        
        @usableFromInline
        init(_ entry: (repeat HealthChartEntry<each Results>)) {
            self.entry = (repeat each entry)
        }
    }
    
    /// :nodoc:
    @inlinable public static func buildExpression<Results>(_ entry: HealthChartEntry<Results>) -> _Tuple<Results> {
        .init((entry))
    }
    
    /// :nodoc:
    @inlinable public static func buildExpression<each Results>(
        _ entry: (repeat HealthChartEntry<each Results>)
    ) -> _Tuple<repeat each Results> {
        .init((repeat each entry))
    }
    
    /// :nodoc:
    @inlinable public static func buildOptional<each Results>(
        _ tuple: HealthChartContentBuilder._Tuple<repeat each Results>?
    ) -> HealthChartContentBuilder._Tuple<repeat each Results> {
        if let tuple {
            tuple
        } else {
            // If we're passed a nil tuple, we instead construct a tuple of same length
            // (needed to keep the return type uniform across both branches), but filled with
            // "empty" entries.
            _Tuple<repeat each Results>((repeat (each Results).makeEmptyHealthChartEntry()))
        }
    }
    
    /// :nodoc:
    @inlinable public static func buildEither<each Results>(
        first tuple: _Tuple<repeat each Results>
    ) -> _Tuple<repeat each Results> {
        tuple
    }
    
    /// :nodoc:
    @inlinable public static func buildEither<each Results>(
        second tuple: _Tuple<repeat each Results>
    ) -> _Tuple<repeat each Results> {
        tuple
    }
    
    /// :nodoc:
    @inlinable public static func buildPartialBlock<each Results>(
        first tuple: _Tuple<repeat each Results>
    ) -> _Tuple<repeat each Results> {
        tuple
    }
    
    /// :nodoc:
    @inlinable public static func buildPartialBlock<each Results, each NextResults>(
        accumulated: (_Tuple<repeat each Results>),
        next: _Tuple<repeat each NextResults>
    ) -> (_Tuple<repeat each Results, repeat each NextResults>) {
        .init((repeat each accumulated.entry, repeat each next.entry))
    }
    
    /// :nodoc:
    @inlinable public static func buildBlock() -> _Tuple<> {
        .init(())
    }
    
    /// :nodoc:
    @inlinable public static func buildFinalResult<each Results>(
        _ tuple: (_Tuple<repeat each Results>)
    ) -> (repeat HealthChartEntry<each Results>) {
        tuple.entry
    }
}


extension HealthKitQueryResults {
    /// Creates a ``HealthChartEntry`` with the empty state, that has its `Results` type bound to the receiver's type.
    /// The reason this function exists, is so that we can map a variadic tuple of type `(repeat A<each T>)`
    /// into one of type `(repeat HealthChartEntry<each T>)`.
    @usableFromInline static func makeEmptyHealthChartEntry() -> HealthChartEntry<Self> {
        HealthChartEntry.makeEmpty()
    }
}
