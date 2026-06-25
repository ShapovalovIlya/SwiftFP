//
//  Distionary.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.03.2025.
//

import Foundation

public extension Dictionary {
    /// Creates a dictionary by evaluating a `@resultBuilder` closure.
    ///
    /// Duplicate keys are resolved by keeping the last value (`{ $1 }`).
    ///
    /// ```swift
    /// let dict: [String: Int] = .init {
    ///     ("a", 1)
    ///     ("b", 2)
    ///     [("c", 3)]
    /// }
    /// ```
    /// - Parameter build: A `@Builder` closure that produces key-value pairs.
    @inlinable
    init(@Array<(Key, Value)>.Builder _ build: () -> [(Key, Value)]) {
        self.init(build(), uniquingKeysWith: { $1 })
    }

    /// Creates a dictionary from an `AsyncSequence` of key-value pairs.
    ///
    /// If multiple pairs share the same key, the last value wins.
    /// - Parameter s: An async sequence of `(Key, Value)` tuples.
    /// - Returns: A dictionary containing all unique key-value pairs.
    @inlinable
    init<S: AsyncSequence>(
        _ s: S
    ) async rethrows where S.Element == (Key, Value) {
        self = try await s.reduce(into: [Key: Value]()) { partialResult, pair in
            partialResult[pair.0] = pair.1
        }
    }

    /// Creates a dictionary from an `AsyncSequence` of key-value pairs with a pre-allocated capacity.
    ///
    /// - Parameters:
    ///   - s: An async sequence of `(Key, Value)` tuples.
    ///   - minimumCapacity: The minimum number of elements the dictionary should reserve space for.
    /// - Returns: A dictionary containing all unique key-value pairs.
    @inlinable
    init<S: AsyncSequence>(
        _ s: S,
        minimumCapacity: Int
    ) async rethrows where S.Element == (Key, Value) {
        self = try await s.reduce(
            into: [Key: Value](minimumCapacity: minimumCapacity)
        ) { partialResult, pair in
            partialResult[pair.0] = pair.1
        }
    }
}
