//
//  Either.swift
//
//
//  Created by Илья Шаповалов on 24.01.2024.
//

import Foundation

/// A type that represents a value of one of two possible types (a disjoint union).
///
/// The ‎`Either` enum is a sum type that can hold a value of either the ‎`Left` or ‎`Right` type, but not both at the same time.
/// This is useful for representing values that can be one of two distinct types, such as the result of a computation that may succeed with one type or fail with another.
///
/// ## Example:
///```swift
/// let success: Either<Int, String> = .left(42)
/// let failure: Either<Int, String> = .right("Error message")
///
/// switch success {
/// case .left(let value):
///     print("Success with value: \(value)")
/// case .right(let error):
///     print("Failure with error: \(error)")
/// }
/// ```
///
/// ‎`Either` provides a variety of functional-style methods for transforming and combining values,
/// such as ‎`map`, ‎`flatMap`, ‎`mapRight`, and ‎`flatMapRight`,
/// as well as subscripts for accessing properties of the contained value via key paths.
/// It also supports asynchronous transformations and applicative operations.
///
/// - Note: Only one of the cases (‎`.left` or ‎`.right`) can be present at any time.
///
@frozen
public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
    
    @inlinable
    public init(branching block: () -> Either) {
        self = block()
    }
    
    //MARK: - subscrips
    @inlinable
    public subscript<T>(left keyPath: KeyPath<Left, T>) -> T? {
        if case .left(let left) = self { return left[keyPath: keyPath] }
        return nil
    }
    
    @inlinable
    public subscript<T>(right keyPath: KeyPath<Right, T>) -> T? {
        if case .right(let right) = self { return right[keyPath: keyPath] }
        return nil
    }
    
    //MARK: - joined()
    @inlinable
    public func joined<T>() -> Either<T,Right> where Left == Either<T,Right> {
        switch self {
        case let .left(wrapped): return wrapped
        case let .right(right): return .right(right)
        }
    }
    
    @inlinable
    public func joinedRight<T>() -> Either<Left,T> where Right == Either<Left,T> {
        switch self {
        case .left(let left): return .left(left)
        case .right(let wrapped): return wrapped
        }
    }
    
    //MARK: - map(_:)
    
    /// Returns a new result, mapping any `left` value using the given transformation.
    /// - Parameter transform: A closure that takes the `left` value of this instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new left value if this instance represents a left branch.
    @inlinable
    public func map<NewLeft>(
        _ transform: (Left) throws -> NewLeft
    ) rethrows -> Either<NewLeft, Right> {
        switch self {
        case let .left(left):
            return try .left(transform(left))
            
        case let .right(right):
            return .right(right)
        }
    }
    
    /// Asynchronously returns a new result, mapping any `left` value using the given transformation.
    /// - Parameter transform: A closure that takes the `left` value of this instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new left value if this instance represents a left branch.
    @inlinable
    public func asyncMap<AsyncLeft>(
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
        switch self {
        case let .left(left):
            return .left(left)
            
        case let .right(right):
            return try .right(transform(right))
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
        try self.map(transform)
            .joined()
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
        try self.mapRight(transform)
            .joinedRight()
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
    public var fold: Left {
        switch self {
        case .left(let left): return left
        case .right(let right): return right
        }
    }
}

extension Either where Left: Error {
    
    /// Transform `Either` into Foundation's `Result` type.
    @inlinable
    func result() -> Result<Right, Left> {
        switch self {
        case .left(let left): return .failure(left)
        case .right(let right): return .success(right)
        }
    }
}

extension Either where Right: Error {
    /// Transform `Either` into Foundation's `Result` type.
    @inlinable
    func result() -> Result<Left, Right> {
        switch self {
        case .left(let left): return .success(left)
        case .right(let right): return .failure(right)
        }
    }
}

extension Either: Equatable where Left: Equatable, Right: Equatable {}
extension Either: Sendable where Left: Sendable, Right: Sendable {}
