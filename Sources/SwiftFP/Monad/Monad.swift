//
//  Monad.swift
//
//
//  Created by Илья Шаповалов on 01.09.2023.
//

import Foundation

/// Monad structure that performs `map`, `flatMap` and `apply` to wrapped value.
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
    @inlinable
    public func apply<U>(
        _ functor: Monad<(Wrapped) -> U>
    ) -> Monad<U> {
        functor.flatMap { transform in
            self.map(transform)
        }
    }
    
    @inlinable
    public func asyncApply<U>(
        _ functor: Monad<(Wrapped) async -> U>
    ) async -> Monad<U> {
        await functor.asyncFlatMap { transform in
            await self.asyncMap(transform)
        }
    }
}

extension Monad: Equatable where Wrapped: Equatable {}

extension Monad: Comparable where Wrapped: Comparable {
    public static func < (lhs: Monad<Wrapped>, rhs: Monad<Wrapped>) -> Bool {
        lhs.value < rhs.value
    }
}
