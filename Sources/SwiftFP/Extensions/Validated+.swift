//
//  Validated+.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 19.03.2025.
//

import Foundation
import Readers
import Validated

public extension Validated {
    /// A `Reader` that validates a `Success` value, producing a `Result`.
    ///
    /// Use this type alias to define validators that depend on the input value:
    /// ```swift
    /// let notEmpty: Validated<String, MyError>.Parser = Reader { str in
    ///     str.isEmpty ? .failure(.empty) : .success(str)
    /// }
    /// ```
    typealias Parser = Reader<Success, Result<Success, Failure>>

    /// Creates a `Validated` by running multiple `Reader`-based parsers against the given state.
    ///
    /// Each parser is a `Reader<Success, Result<Success, Failure>>` — a validator that receives
    /// the input value and returns either the same value (success) or an error.
    ///
    /// - Parameters:
    ///   - state: The value to validate.
    ///   - parsers: An array of `Reader` validators to run against `state`.
    /// - Returns: `.valid(state)` if all parsers succeed, `.invalid(errors)` with accumulated failures.
    @inlinable
    init(_ state: Success, parsers: [Parser]) {
        self.init(
            reduce: state,
            validators: parsers.map { $0.apply(_:) }
        )
    }
}
