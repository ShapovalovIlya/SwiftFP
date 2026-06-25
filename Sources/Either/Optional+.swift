//
//  Optional+.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 20.02.2025.
//

import Foundation

public extension Optional {
    
    /// Converts an optional value to an `Either`.
    ///
    /// - Parameter other: The value to use when the optional is `nil`.
    /// - Returns: `.left(wrapped)` if the optional has a value, `.right(other)` if it's `nil`.
    @inlinable func either<Right>(_ other: Right) -> Either<Wrapped, Right> {
        switch self {
        case .some(let wrapped): return .left(wrapped)
        case .none: return .right(other)
        }
    }
}
