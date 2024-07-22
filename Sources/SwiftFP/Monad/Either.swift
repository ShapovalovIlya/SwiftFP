//
//  Either.swift
//
//
//  Created by Илья Шаповалов on 24.01.2024.
//

import Foundation

/// A value that represents branching, including an associated value in each case.
/// Perform `map`, `flatMap` either `mapRight`, `flatMapRight`.
@frozen
public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
    
    @inlinable
    public init(branching block: () -> Either) {
        self = block()
    }
    
    //MARK: - subscrips
    subscript<T>(left keyPath: KeyPath<Left, T>) -> T? {
        if case .left(let left) = self { return left[keyPath: keyPath] }
        return nil
    }
    
    subscript<T>(right keyPath: KeyPath<Right, T>) -> T? {
        if case .right(let right) = self { return right[keyPath: keyPath] }
        return nil
    }
    
    //MARK: - map(_:)
    
    /// Returns a new result, mapping any `left` value using the given transformation.
    /// - Parameter transform: A closure that takes the `left` value of this instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new left value if this instance represents a left branch.
    @inlinable
    public func map<NewLeft>(
        _ transform: (Left) throws -> NewLeft
    ) rethrows -> Either<NewLeft, Right> {
        try flatMap {
            try .left(transform($0))
        }
    }
    
    /// Asynchronously returns a new result, mapping any `left` value using the given transformation.
    /// - Parameter transform: A closure that takes the `left` value of this instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new left value if this instance represents a left branch.
    @inlinable
    public func map<AsyncLeft>(
        _ transform: (Left) async throws -> AsyncLeft
    ) async rethrows -> Either<AsyncLeft, Right> {
        try await asyncFlatMap { left in
            try await .left(transform(left))
        }
    }
    
    /// Returns a new result, mapping any `right` value using the given transformation.
    /// - Parameter transform: A closure that takes the `right` value of the instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new right value if this instance represents a right branch.
    @inlinable
    public func mapRight<NewRight>(
        _ transform: (Right) throws -> NewRight
    ) rethrows -> Either<Left, NewRight> {
        try flatMapRight {
            try .right(transform($0))
        }
    }
    
    //MARK: - flatMap(_:)
    
    /// Asynchronously returns a new result, mapping any `left` value using the given transformation and unwrapping the produced result.
    /// - Parameter transform: A closure that takes the `left` value of the instance.
    /// - Returns: A `Either` instance, either from the closure or the previous `.right`.
    @inlinable
    public func flatMap<NewLeft>(
        _ transform: (Left) throws -> Either<NewLeft, Right>
    ) rethrows -> Either<NewLeft, Right> {
        switch self {
        case .left(let left):
            return try transform(left)
            
        case .right(let right):
            return .right(right)
        }
    }
    
    /// Returns a new result, mapping any `left` value using the given asynchronous transformation
    /// and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the `left` value of the instance.
    /// - Returns: A `Either` instance, either from the closure or the previous `.right`.
    @inlinable
    public func asyncFlatMap<AsyncLeft>(
        _ transform: (Left) async throws -> Either<AsyncLeft, Right>
    ) async rethrows -> Either<AsyncLeft, Right> {
        switch self {
        case .left(let left):
            return try await transform(left)
            
        case .right(let right):
            return .right(right)
        }
    }
    
    /// Returns a new result, mapping any `right` value using the given transformation and unwrapping the produced result.
    /// - Parameter transform: A closure that takes the `right` value of the instance.
    /// - Returns: A `Either` instance, either from the closure or the previous `.left`.
    @inlinable
    public func flatMapRight<NewRight>(
        _ transform: (Right) throws -> Either<Left, NewRight>
    ) rethrows -> Either<Left, NewRight> {
        switch self {
        case .left(let left):
            return .left(left)
            
        case .right(let right):
            return try transform(right)
        }
    }
    
    /// Returns a new result, mapping any `right` value using the given asynchronous transformation
    /// and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the `right` value of the instance.
    /// - Returns: A `Either` instance, either from the closure or the previous `.left`.
    @inlinable
    public func asyncFlatMapRight<NewRight>(
        _ transform: (Right) async throws -> Either<Left, NewRight>
    ) async rethrows -> Either<Left, NewRight> {
        switch self {
        case .left(let left):
            return .left(left)
            
        case .right(let right):
            return try await transform(right)
        }
    }
    
    //MARK: - apply(_:)
    
    @inlinable
    public func apply<NewLeft>(
        _ other: Either<(Left) -> NewLeft, Right>
    ) -> Either<NewLeft, Right> {
        other.flatMap { transform in
            self.map(transform)
        }
    }
    
    @inlinable
    public func applyRight<NewRight>(
        _ other: Either<Left, (Right) -> NewRight>
    ) -> Either<Left, NewRight> {
        other.flatMapRight { transform in
            self.mapRight(transform)
        }
    }
    
}

extension Either where Left == Right {
    
    /// Return wrapped value if both branches contains same types.
    public var unwrap: Left {
        switch self {
        case .left(let left): return left
        case .right(let right): return right
        }
    }
}

extension Either: Equatable where Left: Equatable, Right: Equatable {}
extension Either: Sendable where Left: Sendable, Right: Sendable {}
