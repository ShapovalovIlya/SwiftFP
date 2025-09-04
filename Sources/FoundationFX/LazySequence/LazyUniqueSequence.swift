//
//  LazyUniqueSequence.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 05.09.2025.
//

import Foundation

/// A lazy sequence that yields only the first occurrence of each unique element, as determined by a hash function.
///
/// `LazyUniqueSequence` wraps a base sequence and produces a new sequence that filters out duplicate elements
/// based on the hash value returned by the provided `hasher` closure. The sequence preserves the order of the
/// first occurrence of each unique element and computes uniqueness lazily as elements are iterated.
///
/// This type is useful for efficiently removing duplicates from a sequence without allocating intermediate storage
/// for all elements, and without requiring the elements themselves to be `Hashable`.
public struct LazyUniqueSequence<Base: Sequence, Hash: Hashable>: LazySequenceProtocol {
    public typealias Element = Base.Element
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let hasher: (Base.Element) -> Hash
    
    @inlinable
    init(base: Base, hasher: @escaping (Base.Element) -> Hash) {
        self.base = base
        self.hasher = hasher
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(base: base.makeIterator(), hasher: hasher)
    }
}

extension LazyUniqueSequence {
    // MARK: - Iterator
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        var base: Base.Iterator
        
        @usableFromInline
        var seen: Set<Hash> = []
        
        @usableFromInline
        let hasher: (Base.Element) -> Hash
        
        @inlinable
        init(base: Base.Iterator, hasher: @escaping (Base.Element) -> Hash) {
            self.base = base
            self.hasher = hasher
        }
        
        @inlinable
        public mutating func next() -> Element? {
            while let element = base.next() {
                guard seen.insert(hasher(element)).inserted else {
                    continue
                }
                return element
            }
            return nil
        }
    }
}
