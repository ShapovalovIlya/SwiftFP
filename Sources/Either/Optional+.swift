//
//  Optional+.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 20.02.2025.
//

import Foundation

public extension Optional {
    
    /// Convert optional value to either.
    /// - Parameter other: If the wrapped is `nil`, given value will be wrapped in `Either` container.
    /// - Returns: `Either` container, that hold's wrapped or other value.
    @inlinable func either<Right>(_ other: Right) -> Either<Wrapped, Right> {
        switch self {
        case .some(let wrapped): return .left(wrapped)
        case .none: return .right(other)
        }
    }
}
