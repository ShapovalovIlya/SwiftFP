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
    func flatMap<NewSuccess>(
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
    func map<NewSuccess>(
        _ asyncTransform: (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        await flatMap { success in
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
    func tryMap<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        await flatMap { success in
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
    
    //MARK: - zip(_:)
    @inlinable
    func merge<T>(_ other: Result<T, Failure>) -> Result<(Success, T), Failure> {
        flatMap { success in
            other.map { (success, $0) }
        }
    }
    
}

public extension Result where Success == Data {
    @inlinable
    func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder) -> Result<T, Error> {
        switch self {
        case .success(let success):
            return Result<T, Error> { try decoder.decode(type.self, from: success) }

        case .failure(let failure):
            return .failure(failure)
        }
    }
}
