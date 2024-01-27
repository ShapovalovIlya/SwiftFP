//
//  Either.swift
//
//
//  Created by Илья Шаповалов on 24.01.2024.
//

import Foundation

/// A value that represents either a success or a failure, including an associated value in each case.
/// Perform `map`, `flatMap` either `mapFailure`, `flatMapFailure`.
public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
    
    //MARK: - map(_:)
    /// Returns a new result, mapping any `left` value using the given transformation.
    /// - Parameter transform: A closure that takes the `left` value of this instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new left value if this instance represents a left branch.
    @inlinable
    public func map<NewLeft>(
        _ transform: (Left) throws -> NewLeft
    ) rethrows -> Either<NewLeft, Right> {
        switch self {
        case .left(let left):
            return try .left(transform(left))
            
        case .right(let right):
            return .right(right)
        }
    }
    
    /// Returns a new result, mapping any `right` value using the given transformation.
    /// - Parameter transform: A closure that takes the `right` value of the instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new right value if this instance represents a right branch.
    @inlinable
    public func mapRight<NewRight>(
        _ transform: (Right) throws -> NewRight
    ) rethrows -> Either<Left, NewRight> {
        switch self {
        case .left(let left):
            return .left(left)
        case .right(let right):
            return try .right(transform(right))
        }
    }
    
    //MARK: - flatMap(_:)
    /// Returns a new result, mapping any `left` value using the given transformation and unwrapping the produced result.
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
    
    /// Returns a new value, mapping any result from `Either` using the given transformation.
    /// - Parameter transform: A closure that takes the unwrapped value of the instance.
    /// - Returns: A new type instance, from the closure.
    @inlinable
    public func flatMap<T>(
        _ transform: (Either<Left, Right>) throws -> T
    ) rethrows -> T {
        try transform(self)
    }
    
    //MARK: - apply(_:)
    @inlinable
    public func apply<NewLeft>(
        _ other: Either<(Left) -> NewLeft, Right>
    ) -> Either<NewLeft, Right> {
        switch other {
        case .left(let transform):
            return self.map(transform)
            
        case .right(let right):
            return .right(right)
        }
    }
    
    @inlinable
    public func applyRight<NewRight>(
        _ other: Either<Left, (Right) -> NewRight>
    ) -> Either<Left, NewRight> {
        switch other {
        case .left(let left):
            return .left(left)
            
        case .right(let transform):
            return self.mapRight(transform)
        }
    }
}
