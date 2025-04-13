//
//  AsyncAdapterSequence.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 13.04.2025.
//

import Foundation

public struct AsyncAdapterSequence<Base: Sequence>: AsyncSequence {
    public typealias Element = Base.Element
    
    @usableFromInline let base: Base
    
    @inlinable
    init(_ base: Base) { self.base = base }
    
    @inlinable
    public func makeAsyncIterator() -> Iterator {
        Iterator(base: base.makeIterator())
    }
}

extension AsyncAdapterSequence {
    //MARK: - Iterator
    @frozen
    public struct Iterator: AsyncIteratorProtocol {
        @usableFromInline var base: Base.Iterator
        
        @inlinable
        init(base: Base.Iterator) { self.base = base }
        
        @inlinable
        public mutating func next() async throws -> Base.Element? {
            if Task.isCancelled { return nil }
            return base.next()
        }
    }
}
