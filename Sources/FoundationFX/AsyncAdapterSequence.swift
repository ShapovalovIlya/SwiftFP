//
//  AsyncAdapterSequence.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 13.04.2025.
//

import Foundation

/// An asynchronous adapter for any synchronous sequence.
///
/// `AsyncAdapterSequence` wraps a standard `Sequence` and exposes it as an `AsyncSequence`,
/// enabling asynchronous iteration using Swift concurrency. This is useful for bridging
/// existing synchronous collections or sequences into asynchronous contexts, such as when
/// using `for await` loops.
///
/// The adapter supports cooperative cancellation: if the surrounding `Task` is cancelled,
/// iteration will stop and the underlying iterator will be released.
///
/// - Note: The underlying sequence is iterated lazily, one element at a time, as the async iterator advances.
/// - Important: If the sequence is infinite, the async sequence will never finish unless cancelled.
///
/// - Parameters:
///   - Base: The type of the underlying sequence.
/// - Conforms To: `AsyncSequence`
/// - SeeAlso: ``_Concurrency/AsyncSequence``
@frozen
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
    
    /// An asynchronous iterator over the elements of the adapted sequence.
    ///
    /// The iterator checks for task cancellation before yielding each element.
    @frozen
    public struct Iterator: AsyncIteratorProtocol {
        @usableFromInline var base: Base.Iterator?
        
        @inlinable
        init(base: Base.Iterator) { self.base = base }
        
        /// Returns the next element in the sequence, or `nil` if the sequence is exhausted or the task is cancelled.
        ///
        /// - Returns: The next element, or `nil` if finished or cancelled.
        @inlinable
        public mutating func next() async -> Base.Element? {
            if Task.isCancelled {
                base = nil
                return nil
            }
            return base?.next()
        }
    }
}
