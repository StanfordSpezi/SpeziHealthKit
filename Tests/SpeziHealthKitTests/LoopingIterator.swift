//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// An iterator that will loop over a collection, and never stop.
public struct LoopingCollectionIterator<Base: Collection>: IteratorProtocol {
    public typealias Element = Base.Element
    
    /// The collection we want to provide looping iteration over.
    private let base: Base
    /// The current iteration state, i.e. the index of the next element to be yielded from the iterator.
    private var idx: Base.Index
    
    fileprivate init(_ base: Base) {
        self.base = base
        self.idx = base.startIndex
    }
    
    public mutating func next() -> Element? {
        defer {
            base.formIndex(after: &idx)
            if idx >= base.endIndex {
                idx = base.startIndex
            }
        }
        return base[idx]
    }
    
    /// "Resets" the iterator to the beginning of the collection.
    /// The next call to ``LoopingIterator.next()`` will yield the collection's first element.
    public mutating func reset() {
        idx = base.startIndex
    }
}


extension Collection {
    /// Turns the collection into a looping iterator.
    public func makeLoopingIterator() -> LoopingCollectionIterator<Self> {
        LoopingCollectionIterator(self)
    }
}
