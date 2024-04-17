//
//  Optional.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation

public extension Optional {
    
    @inlinable
    func apply<NewWrapped>(
        _ other: Optional<(Wrapped) -> NewWrapped>
    ) -> Optional<NewWrapped> {
        other.flatMap { transform in
            self.map(transform)
        }
    }
       
    /// Merge two optional values.
    /// - Parameter other: optional value to combine with
    /// - Returns: `Optional tuple` containing two upstream values or `nil` if any of them is `nil`
    @inlinable
    func merge<T>(_ other: T?) -> Optional<(Wrapped, T)> {
        flatMap { wrapped in
            other.map { (wrapped, $0) }
        }
    }
    
    @inlinable
    func asyncMap<T>(
        _ transform: (Wrapped) async throws -> T
    ) async rethrows -> T? {
        switch self {
        case .none:
            return .none
        case .some(let wrapped):
            let transformed = try await transform(wrapped)
            return .some(transformed)
        }
    }

}
