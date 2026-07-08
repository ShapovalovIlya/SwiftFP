//
//  Array.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.08.2024.
//

import Foundation

/// A shorthand for `Array<T>.Builder`.
public typealias BuilderOf<T> = Array<T>.Builder

public extension Set {
    /// Creates a `Set` from a `@resultBuilder` closure.
    ///
    /// - Parameter build: A `@Builder` closure that produces an array of elements.
    /// - Returns: A set containing all elements produced by the builder.
    /// - Deprecated: Use `Set.build` instead.
    @available(*, deprecated, message: "Use Set.build instead")
    @inlinable
    init(@Array<Element>.Builder _ build: () -> [Element]) {
        self = Set(build())
    }

    /// Creates a `Set` by evaluating a throwing `@resultBuilder` closure.
    ///
    /// ```swift
    /// let set: Set<Int> = .build {
    ///     1
    ///     2
    ///     [3, 4]
    /// }
    /// ```
    /// - Parameter build: A `@Builder` closure that produces an array of elements.
    /// - Returns: A set containing all elements produced by the builder.
    @inlinable
    static func build<E: Error>(@BuilderOf<Element> _ build: () throws(E) -> [Element]) rethrows -> Self {
        Set(try build())
    }
}

public extension Array {
    //MARK: - init(_:)

    /// Creates an array from a `@resultBuilder` closure.
    ///
    /// - Parameter build: A `@Builder` closure that produces an array of elements.
    /// - Deprecated: Use `Array.build` instead.
    @available(*, deprecated, message: "Use Array.build instead")
    @inlinable
    init(@Builder _ build: () throws -> [Element]) rethrows { self = try build() }

    /// Creates an array from an `AsyncSequence`.
    ///
    /// Collects all elements from the async sequence into a single array.
    /// - Parameter s: An async sequence whose elements to collect.
    /// - Returns: An array containing all elements from the async sequence.
    @inlinable
    init<S: AsyncSequence>(_ s: S) async rethrows where S.Element == Element {
        self = try await s.reduce(into: [Element]()) { $0.append($1) }
    }

    /// Creates an array by evaluating a throwing `@resultBuilder` closure.
    ///
    /// ```swift
    /// let array = Array.build {
    ///     1
    ///     2
    ///     [3, 4]
    ///     if condition { 5 }
    /// }
    /// ```
    /// - Parameter build: A `@Builder` closure that produces an array of elements.
    /// - Returns: An array containing all elements produced by the builder.
    @inlinable
    static func build<E:Error>(@Builder _ build: () throws(E) -> [Element]) rethrows -> Self {
        try build()
    }

    //MARK: - Builder

    /// A result builder for constructing arrays in a declarative DSL.
    ///
    /// Supports expressions of type `Element`, `[Element]`, `Void`, `Optional<[Element]>`,
    /// and `Either<[Element]>`. Use it with `Array.build` or `Set.build`.
    ///
    /// ```swift
    /// let array = Array.build {
    ///     1                    // single element
    ///     [2, 3]              // array of elements
    ///     if condition { 4 }  // optional element
    /// }
    /// ```
    @resultBuilder
    enum Builder {
        @inlinable
        public static func buildExpression(_ expression: Void) -> [Element] {
            []
        }

        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            expression
        }

        @inlinable
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            components.flatMap(\.self)
        }

        @inlinable
        public static func buildBlock(_ components: [Element]...) -> [Element] {
            buildArray(components)
        }

        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first component: [Element]) -> [Element] {
            component
        }

        @inlinable
        public static func buildEither(second component: [Element]) -> [Element] {
            component
        }
    }
}
