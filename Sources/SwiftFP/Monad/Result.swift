//
//  Result.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation
 
public extension Result where Failure == Error {
    
    //MARK: - init(_:)
    
    /// Asynchronously Creates a new result by evaluating a asynchronous throwing closure,
    /// capturing the returned value as a success, or any thrown error as a failure.
    /// - Parameter body: A asynchronous throwing closure to evaluate.
    @inlinable
    init(asyncCatch body: () async throws -> Success) async {
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
    
    //MARK: - flatMap(_:)
    
    /// Returns a new result, asynchronous mapping any success value using the given `transformation`
    /// and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the success value of the instance.
    /// - Returns: A `Result` instance, either from the closure or the previous `.failure`.
    @inlinable
    @discardableResult
    func asyncFlatMap<NewSuccess>(
        _ asyncTransform: (Success) async -> Result<NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await asyncTransform(success)
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    //MARK: - map(_:)
    
    /// Returns a new result, mapping any success value using the given asynchronous transformation.
    /// - Parameter asyncTransform: A asynchronous closure that takes the success value of this instance.
    /// - Returns: A Result instance with the result of evaluating `asyncTransform` as the new success value
    /// if this instance represents a success.
    @inlinable
    @discardableResult
    func asyncMap<NewSuccess>(
        _ asyncTransform: (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        await asyncFlatMap { success in
            await .success(asyncTransform(success))
        }
    }
    
    /// Returns a new result, mapping any success value using the given throwing transformation.
    /// - Parameter transform: A throwing closure that takes the success value of this instance.
    /// - Returns: A Result instance with the result of evaluating `transformation` as the new success value
    /// if this instance represents a success.
    @inlinable
    func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Failure> {
        flatMap { success in
            Result<NewSuccess, Failure> { try transform(success) }
        }
    }
    
    /// Returns a new result, mapping any success value using the given asynchronous throwing transformation.
    /// - Parameter transform: A asynchronous throwing closure that takes the success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating `transformation` as the new success value
    /// if this instance represents a success.
    @inlinable
    func asyncTryMap<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        await asyncFlatMap { success in
            await Result<NewSuccess, Failure> { try await transform(success) }
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
        functor.flatMap { transform in
            self.map(transform)
        }
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
        await functor.asyncFlatMap { transform in
            await self.asyncMap(transform)
        }
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
    
}

public extension Result where Success == Data, Failure == Error {
    @inlinable
    func decode<T: Decodable>(
        _ type: T.Type, decoder: JSONDecoder
    ) -> Result<T, Failure> {
        flatMap { success in
            Result<T, Failure> { try decoder.decode(type.self, from: success) }
        }
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
) -> Result<(Success1, Success2), Error> {
    lhs.zip(rhs)
}
