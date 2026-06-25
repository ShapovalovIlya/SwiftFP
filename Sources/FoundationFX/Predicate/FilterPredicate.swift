//
//  FilterPredicate.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.05.2025.
//

import Foundation

/// A composable predicate for filtering sequences.
///
/// `FilterPredicate` wraps a `(Input) -> Bool` closure and provides fluent combinators
/// (`and`, `or`, `not`) as well as operator overloads (`&&`, `||`) to build complex
/// conditions in a readable way.
///
/// ### Example
///
/// ```swift
/// let isAdult = FilterPredicate<Int> { $0 >= 18 }
/// let isSenior = FilterPredicate<Int> { $0 >= 65 }
///
/// let combined = isAdult && !isSenior
/// ages.filter(combined)  // ages >= 18 and < 65
/// ```
@frozen
public struct FilterPredicate<Input> {
    @usableFromInline let validate: (Input) -> Bool

    /// Creates a predicate from a closure.
    /// - Parameter validate: A closure that returns `true` if the input satisfies the condition.
    @inlinable
    init(_ validate: @escaping (Input) -> Bool) {
        self.validate = validate
    }

    /// Creates a predicate that always returns the same value.
    /// - Parameter value: The constant result for any input.
    /// - Returns: A predicate that ignores its input and returns `value`.
    @inlinable
    static func pure(_ value: Bool) -> FilterPredicate<Input> {
        FilterPredicate<Input> { _ in value }
    }

    /// Tests whether the given input satisfies this predicate.
    /// - Parameter input: The value to test.
    /// - Returns: `true` if the input satisfies the condition.
    @inlinable
    func satisfied(_ input: Input) -> Bool {
        validate(input)
    }

    /// Returns a predicate that inverts this predicate's result.
    @inlinable
    var not: FilterPredicate<Input> {
        FilterPredicate<Input> { !self.satisfied($0) }
    }

    /// Combines this predicate with a closure using logical AND.
    /// - Parameter isSatisfied: A closure to AND with this predicate.
    /// - Returns: A predicate that is satisfied when both conditions are true.
    @inlinable
    func and(_ isSatisfied: @escaping (Input) -> Bool) -> FilterPredicate<Input> {
        FilterPredicate<Input> { input in
            self.satisfied(input) && isSatisfied(input)
        }
    }

    /// Combines this predicate with a closure using logical OR.
    /// - Parameter isSatisfied: A closure to OR with this predicate.
    /// - Returns: A predicate that is satisfied when either condition is true.
    @inlinable
    func or(_ isSatisfied: @escaping (Input) -> Bool) -> FilterPredicate<Input> {
        FilterPredicate<Input> { input in
            self.satisfied(input) || isSatisfied(input)
        }
    }

    /// Combines this predicate with another using a custom boolean combinator.
    /// - Parameters:
    ///   - other: Another predicate to combine with.
    ///   - combinator: A closure that combines the results of both predicates.
    /// - Returns: A predicate that evaluates `combinator(self, other)` for each input.
    @inlinable
    func zip(
        _ other: FilterPredicate<Input>,
        using combinator: @escaping (Bool, Bool) -> Bool
    ) -> FilterPredicate<Input> {
        FilterPredicate<Input> { input in
            let lhs = self.satisfied(input)
            let rhs = other.satisfied(input)
            return combinator(lhs, rhs)
        }
    }

    /// Combines this predicate with another using logical AND.
    /// - Parameter other: Another predicate to AND with.
    /// - Returns: A predicate satisfied when both are true.
    @inlinable
    func and(_ other: FilterPredicate<Input>) -> FilterPredicate<Input> {
        zip(other, using: { $0 && $1 })
    }

    /// Combines this predicate with another using logical OR.
    /// - Parameter other: Another predicate to OR with.
    /// - Returns: A predicate satisfied when either is true.
    @inlinable
    func or(_ other: FilterPredicate<Input>) -> FilterPredicate<Input> {
        zip(other, using: { $0 || $1 })
    }

    /// Returns a predicate that is satisfied when this predicate is true and `other` is false.
    /// - Parameter other: The predicate to subtract.
    /// - Returns: A predicate equivalent to `self && !other`.
    @inlinable
    func not(_ other: FilterPredicate<Input>) -> FilterPredicate<Input> {
        zip(other.not, using: { $0 && $1 })
    }

    /// Combines two predicates using logical AND.
    @inlinable
    static func && (
        lhs: FilterPredicate<Input>,
        rhs: FilterPredicate<Input>
    ) -> FilterPredicate<Input> {
        lhs.and(rhs)
    }

    /// Combines two predicates using logical OR.
    @inlinable
    static func || (
        lhs: FilterPredicate<Input>,
        rhs: FilterPredicate<Input>
    ) -> FilterPredicate<Input> {
        lhs.or(rhs)
    }
}

public extension Sequence {
    /// Filters this sequence using a `FilterPredicate`.
    /// - Parameter predicate: The predicate to test each element.
    /// - Returns: An array of elements that satisfy the predicate.
    @inlinable
    func filter(_ predicate: FilterPredicate<Element>) -> [Element] {
        filter(predicate.satisfied)
    }
}

public extension LazySequenceProtocol {
    /// Lazily filters this sequence using a `FilterPredicate`.
    /// - Parameter predicate: The predicate to test each element.
    /// - Returns: A lazy filter sequence of elements that satisfy the predicate.
    @inlinable
    func filter(_ predicate: FilterPredicate<Element>) -> LazyFilterSequence<Elements> {
        self.filter(predicate.satisfied)
    }
}

public extension LazyCollectionProtocol {
    /// Lazily filters this collection using a `FilterPredicate`.
    /// - Parameter predicate: The predicate to test each element.
    /// - Returns: A lazy filter collection of elements that satisfy the predicate.
    @inlinable
    func filter(_ predicate: FilterPredicate<Element>) -> LazyFilterCollection<Elements> {
        self.filter(predicate.satisfied)
    }
}
