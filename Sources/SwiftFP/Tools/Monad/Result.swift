//
//  Result.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation
 
public extension Result where Failure == Error {
    
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
    
    /// Returns a new result, asynchronous mapping any success value using the given `transformation` 
    /// and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the success value of the instance.
    /// - Returns: A `Result` instance, either from the closure or the previous `.failure`.
    @inlinable
    func flatMap<T>(
        _ asyncTransform: (Success) async -> Result<T, Failure>
    ) async -> Result<T, Failure> {
        switch self {
        case .success(let success):
            return await asyncTransform(success)
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, mapping any success value using the given asynchronous transformation.
    /// - Parameter asyncTransform: A asynchronous closure that takes the success value of this instance.
    /// - Returns: A Result instance with the result of evaluating `asyncTransform` as the new success value
    /// if this instance represents a success.
    @inlinable
    func map<T>(_ asyncTransform: (Success) async -> T) async -> Result<T, Failure> {
        await flatMap { success in
            await .success(asyncTransform(success))
        }
    }
    
    /// Returns a new result, mapping any success value using the given throwing transformation.
    /// - Parameter transform: A throwing closure that takes the success value of this instance.
    /// - Returns: A Result instance with the result of evaluating `transformation` as the new success value
    /// if this instance represents a success.
    @inlinable
    func tryMap<T>(_ transform: (Success) throws -> T) -> Result<T, Failure> {
        flatMap { success in
            Result<T, Failure> { try transform(success) }
        }
    }
    
    @inlinable
    func tryMap<T>(_ transform: (Success) async throws -> T) async -> Result<T, Failure> {
        await flatMap { success in
            await Result<T, Failure> { try await transform(success) }
        }
    }
    
    @inlinable
    @discardableResult
    func apply<NewSuccess>(
        _ other: Result<(Success) -> NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure> {
        other.flatMap { transform in
            self.map(transform)
        }
    }
    
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
