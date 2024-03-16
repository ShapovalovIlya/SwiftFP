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
        switch other {
        case .none:
            return .none

        case .some(let transform):
            return self.map(transform)
        }
    }
       
    
    /// Merge two optional values.
    /// - Parameter other: optional value to combine with
    /// - Returns: `Optional tuple` containing two upstream values or `nil` if any of them is `nil`
    @inlinable
    func merge<T>(_ other: T?) -> Optional<(Wrapped, T)> {
        guard let self, let other else {
            return nil
        }
        return Optional<(Wrapped, T)>((self, other))
    }

}
