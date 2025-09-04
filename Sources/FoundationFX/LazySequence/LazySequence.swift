//
//  LazySequence.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 05.09.2025.
//

import Foundation

public extension LazySequence {
    
    /// Returns a `LazyMapSequence` over this sequence.
    /// The elements of the result are computed lazily, each time they are accessed, by applying each function in the sequence to the given `value`.
    @inlinable
    func apply<A,B>(_ value: A) -> LazyMapSequence<Self, B> where Element == (A) -> B {
        self.lazy.map { $0(value) }
    }
    
    /// Returns a lazy sequence containing only the first occurrence of each unique element, as determined by the provided identity function.
    ///
    /// This method creates a `LazyUniqueSequence` that filters out duplicate elements from the sequence.
    /// Uniqueness is determined by the value returned from the `identityOf` closure for each element.
    /// The sequence preserves the order of the first occurrence of each unique element and computes uniqueness lazily as elements are iterated.
    ///
    /// - Parameter identityOf: A closure that takes an element of the sequence and returns a hashable value used to determine uniqueness.
    /// - Returns: A `LazyUniqueSequence` containing only the first occurrence of each unique element.
    ///
    /// ### Example
    /// ```swift
    /// let numbers = [1, 2, 2, 3, 1, 4]
    /// let uniqueNumbers = numbers.lazy.unique(identityOf: { $0 })
    /// Array(uniqueNumbers) // [1, 2, 3, 4]
    ///
    /// let words = ["apple", "banana", "apricot", "blueberry"]
    /// // Unique by first letter
    /// let uniqueByFirstLetter = words.lazy.unique(identityOf: { $0.first! })
    /// Array(uniqueByFirstLetter) // ["apple", "banana"]
    /// ```
    @inlinable
    func unique<T: Hashable>(identityOf: @escaping (Element) -> T) -> LazyUniqueSequence<Self, T> {
        LazyUniqueSequence(base: self, hasher: identityOf)
    }
}

public extension LazySequence where Element: Hashable {
    
    /// Returns a lazy sequence containing only the first occurrence of each unique element in the sequence.
    ///
    /// This method creates a `LazyUniqueSequence` that filters out duplicate elements from the sequence.
    /// Uniqueness is determined by the element's own value, so elements must conform to `Hashable`.
    /// The sequence preserves the order of the first occurrence of each unique element and computes uniqueness lazily as elements are iterated.
    ///
    /// - Returns: A `LazyUniqueSequence` containing only the first occurrence of each unique element.
    ///
    /// ### Example
    /// ```swift
    /// let numbers = [1, 2, 2, 3, 1, 4]
    /// let uniqueNumbers = numbers.lazy.unique()
    /// Array(uniqueNumbers) // [1, 2, 3, 4]
    /// ```
    @inlinable
    func unique() -> LazyUniqueSequence<Self, Element> {
        LazyUniqueSequence(base: self, hasher: \.self)
    }
}
