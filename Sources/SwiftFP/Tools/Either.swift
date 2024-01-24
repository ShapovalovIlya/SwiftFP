//
//  Either.swift
//
//
//  Created by Илья Шаповалов on 24.01.2024.
//

import Foundation

/// A value that represents either a success or a failure, including an associated value in each case.
/// Perform `map`, `flatMap` either `mapFailure`, `flatMapFailure`.
public enum Either<Success, Failure> {
    case success(Success)
    case failure(Failure)
    
    /// Returns a new result, mapping any success value using the given transformation.
    /// - Parameter transform: A closure that takes the success value of this instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new success value if this instance represents a success.
    @inlinable
    public func map<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) rethrows -> Either<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return try .success(transform(success))
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, mapping any failure value using the given transformation.
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: A `Either` instance with the result of evaluating `transform` as the new failure value if this instance represents a failure.
    @inlinable
    public func mapFailure<NewFailure>(
        _ transform: (Failure) throws -> NewFailure
    ) rethrows -> Either<Success, NewFailure> {
        switch self {
        case .success(let success): 
            return .success(success)
        case .failure(let failure):
            return try .failure(transform(failure))
        }
    }
    
    /// Returns a new result, mapping any success value using the given transformation and unwrapping the produced result.
    /// - Parameter transform: A closure that takes the success value of the instance.
    /// - Returns: A `Either` instance, either from the closure or the previous .failure.
    @inlinable
    public func flatMap<NewSuccess>(
        _ transform: (Success) throws -> Either<NewSuccess, Failure>
    ) rethrows -> Either<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return try transform(success)
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, mapping any failure value using the given transformation and unwrapping the produced result.
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: A `Either` instance, either from the closure or the previous .success.
    @inlinable
    public func flatMapFailure<NewFailure>(
        _ transform: (Failure) throws -> Either<Success, NewFailure>
    ) rethrows -> Either<Success, NewFailure> {
        switch self {
        case .success(let success):
            return .success(success)
            
        case .failure(let failure):
            return try transform(failure)
        }
    }
    
    /// Returns a new value, mapping any result from `Either` using the given transformation.
    /// - Parameter transform: A closure that takes the unwrapped value of the instance.
    /// - Returns: A new type instance, from the closure.
    @inlinable
    public func flatMap<T>(
        _ transform: (Either<Success, Failure>) throws -> T
    ) rethrows -> T {
        try transform(self)
    }
}
