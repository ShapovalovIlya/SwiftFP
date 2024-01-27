//
//  Result.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation

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
}
 
public extension Result {
    
    /// Apply other Result evaluating it's closure with wrapped success value, 
    /// - Parameter other: <#other description#>
    /// - Returns: <#description#>
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
}
