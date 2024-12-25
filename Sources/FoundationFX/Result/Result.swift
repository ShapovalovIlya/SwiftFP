//
//  Result.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation
@_exported import Either

public extension Result {
    //MARK: - init(_:)
    
    /// Asynchronously Creates a new result by evaluating a asynchronous throwing closure,
    /// capturing the returned value as a success, or any thrown error as a failure.
    /// - Parameter body: A asynchronous throwing closure to evaluate.
    @inlinable
    init(asyncCatch body: () async throws(Failure) -> Success) async {
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
    
    //MARK: - map(_:)
    /// Returns a new result, mapping any success value using the given throwing transformation.
    /// - Parameter transform: A throwing closure that takes the success value of this instance.
    /// - Returns: A Result instance with the result of evaluating `transformation` as the new success value
    /// if this instance represents a success.
    @inlinable
    func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Error> {
        switch self {
        case .success(let success):
            return Result<NewSuccess, Error> { try transform(success) }
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, mapping any success value using the given asynchronous transformation.
    /// - Parameter transform: A asynchronous closure that takes the success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform` as the new success value
    /// if this instance represents a success.
    @inlinable
    func asyncMap<NewSuccess>(
        _ transform: (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await Result<NewSuccess, Failure> { await transform(success) }
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, mapping any success value using the given asynchronous throwing transformation.
    /// - Parameter transform: A asynchronous throwing closure that takes the success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform` as the new success value
    /// if this instance represents a success.
    @inlinable
    func asyncTryMap<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess
    ) async -> Result<NewSuccess, Error> {
        switch self {
        case .success(let success):
            return await Result<NewSuccess, Error> {
                try await transform(success)
            }
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    //MARK: - apply(_:)
    
    /// Returns a new result, apply `Result` functor to  success value.
    /// - Parameter functor: A `Result` functor that takes success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating stored function as the new success value.
    /// If any of given `Result` instances are failure, then produced `Result` will be failure.
    @inlinable
    @discardableResult
    func apply<NewSuccess>(
        _ functor: Result<(Success) -> NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure> {
        functor
            .map(self.map)
            .flatMap(\.self)
    }
    
    /// Asynchronously returns a new result, apply `Result` functor to  success value.
    /// - Parameter functor: A `Result` functor that takes success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating stored function as the new success value.
    /// If any of given `Result` instances are failure, then produced `Result` will be failure.
    @inlinable
    @discardableResult
    func asyncApply<NewSuccess>(
        _ functor: Result<@Sendable (Success) async -> NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        await functor
            .asyncMap(self.asyncMap)
            .flatMap(\.self)
    }
    
    //MARK: - flatMap(_:)
    
    /// Returns a new result, asynchronous mapping any success value using the given `transformation`
    /// and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the success value of the instance.
    /// - Returns: A `Result` instance, either from the closure or the previous `.failure`.
    @inlinable
    func asyncFlatMap<NewSuccess>(
        _ transform: (Success) async -> Result<NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        await asyncMap(transform).flatMap(\.self)
    }
    
    //MARK: - zip(_:)
    
    /// Zip two `Result` values
    /// - Parameter other: `Result` object to zip with
    /// - Returns: `Result` containing two upstream values in `tuple` or `failure`,
    /// if any of upstream results is `failure`.
    @inlinable
    func zip<Other>(_ other: Result<Other, Failure>) -> Result<(Success, Other), Failure> {
        flatMap { success in
            other.map { (success, $0) }
        }
    }
    
    @inlinable
    func reduce<T>(_ body: (Self) throws -> T) rethrows -> T {
        try body(self)
    }
    
    @inlinable
    func either() -> Either<Success, Failure> {
        switch self {
        case .success(let success): return .left(success)
        case .failure(let failure): return .right(failure)
        }
    }
}

public extension Result where Success == Data {
    @inlinable
    func decodeJSON<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder
    ) -> Result<T, Error> {
        tryMap { try decoder.decode(type.self, from: $0) }
    }
}

extension Result: Sendable where Success: Sendable, Failure: Sendable {}

/// Creates a `Result` of pairs built out of two underlying `Results`.
/// - Parameters:
///   - lhs: The first `Result` to zip.
///   - rhs: The second `Result` to zip.
/// - Returns: A `Result` of tuple pair, where the elements of pair are
///   corresponding `success` of `lhs` and `rhs`, or `failure` if any of instances is `failure`.
@inlinable
public func zip<Success1, Success2>(
    _ lhs: Result<Success1, Error>,
    _ rhs: Result<Success2, Error>
) -> Result<(Success1, Success2), Error> { lhs.zip(rhs) }
