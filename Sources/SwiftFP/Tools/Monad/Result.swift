//
//  Result.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation
 
public extension Result {
    
    /// Returns a new result, asynchronous mapping any success value using the given `transformation` and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the success value of the instance.
    /// - Returns: A `Result` instance, either from the closure or the previous `.failure`.
    @inlinable
    func asyncFlatMap<T>(
        _ transform: (Success) async -> Result<T, Failure>
    ) async -> Result<T, Failure> {
        switch self {
        case .success(let success):
            return await transform(success)
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    @inlinable
    func apply<NewSuccess>(
        _ other: Result<(Success) -> NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure> {
        switch other {
        case .success(let transform):
            return self.map(transform)
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    @inlinable
    func merge<T>(_ other: Result<T, Failure>) -> Result<(Success, T), Failure> {
        flatMap { success in
            other.map { (success, $0) }
        }
    }
}

public extension Result where Failure == Error {
    
    /// Creates a new result by evaluating a asynchronous throwing closure, capturing the returned value as a success, or any thrown error as a failure.
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
    
    
    /// Returns a new result, asynchronous mapping any success value using the given transformation.
    /// - Parameter transform: A asynchronous closure that takes the success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform` as the new success value if this instance represents a success.
    @inlinable
    func asyncMap<T>(
        _ transform: (Success) async throws -> T
    ) async -> Result<T, Failure> {
        switch self {
        case .success(let success):
            return await Result<T, Failure> { try await transform(success) }
            
        case .failure(let failure):
            return .failure(failure)
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
