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
}
