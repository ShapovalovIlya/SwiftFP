//
//  Monad.swift
//
//
//  Created by Илья Шаповалов on 01.09.2023.
//

import Foundation

/// Monad structure that performs `map`, `flatMap` and `apply` to wrapped value.
@frozen
@dynamicMemberLookup
public struct Monad<Wrapped> {
    public let value: Wrapped
    
    //MARK: - init(_:)
    /// Creates an instance that stores the given value.
    @inlinable
    public init(_ value: Wrapped) { self.value = value }

    //MARK: - subscript
    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<Wrapped, T>) -> T {
        value[keyPath: keyPath]
    }
    
    //MARK: - map(_:)
    
    /// Evaluates the given closure, passing the unwrapped value as a parameter.
    /// - Parameter transform: A closure that takes the unwrapped value of the instance.
    /// - Returns: The result of the given closure wrapped in `Monad`.
    @inlinable
    public func map<U>(
        _ transform: (Wrapped) throws -> U
    ) rethrows -> Monad<U> {
        Monad<U>(try transform(value))
    }
    
    /**
     Evaluates the given asynchronous closure, passing the unwrapped value as a parameter.
      - Parameter transform: A asynchronous closure that takes the unwrapped value of the instance.
      - Returns: The asynchronous result of the given closure wrapped in `Monad`.
     */
    @inlinable
    public func asyncMap<U>(
        _ transform: (Wrapped) async throws -> U
    ) async rethrows -> Monad<U> {
        Monad<U>(try await transform(value))
    }
    
    //MARK: - flatMap(_:)
    @inlinable
    public func flatMap<U>(
        _ transform: (Wrapped) throws -> Monad<U>
    ) rethrows -> Monad<U> {
        try transform(value)
    }
    
    @inlinable
    public func asyncFlatMap<U>(
        _ transform: (Wrapped) async throws -> Monad<U>
    ) async rethrows -> Monad<U> {
        try await transform(value)
    }
    
    //MARK: - apply(_:)
    
    /// Evaluate given function with value as input parameter
    /// - Parameter functor: a `Monad` instance with function as wrapped value
    /// - Returns: The result of given function wrapped in `Monad`
    @inlinable
    public func apply<U>(
        _ functor: Monad<(Wrapped) -> U>
    ) -> Monad<U> {
        functor.flatMap { transform in
            self.map(transform)
        }
    }
    
    /// Evaluate given asynchronous function with value as input parameter
    /// - Parameter functor: a `Monad` instance with asynchronous function as wrapped value
    /// - Returns: The result of given function wrapped in `Monad`
    @inlinable
    @discardableResult
    @Sendable
    public func asyncApply<U>(
        _ functor: Monad<@Sendable (Wrapped) async -> U>
    ) async -> Monad<U> {
        await functor.asyncFlatMap { transform in
            await self.asyncMap(transform)
        }
    }
    
    //MARK: - zip(_:_:)
    
    /// Zip with other `Monad` instance
    /// - Parameter other: a `Monad` to combine with
    /// - Returns: result `Monad` contains pair of two upstream values
    @inlinable
    public func zip<U>(_ other: Monad<U>) -> Monad<(Wrapped, U)> {
        flatMap { wrapped in
            other.map { (wrapped, $0) }
        }
    }
}

/// Zip two `Monad` instances
/// - Parameters:
///   - lhs: first `Monad` to combine with
///   - rhs: second `Monad` to combine with
/// - Returns: result `Monad` contains pair of two upstream values
@inlinable
public func zip<A, B>(_ lhs: Monad<A>, _ rhs: Monad<B>) -> Monad<(A, B)> {
    lhs.zip(rhs)
}

extension Monad: Equatable where Wrapped: Equatable {}

extension Monad: Comparable where Wrapped: Comparable {
    @inlinable
    public static func < (lhs: Monad<Wrapped>, rhs: Monad<Wrapped>) -> Bool {
        lhs.value < rhs.value
    }
}
