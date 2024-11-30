//
//  Sequence.swift
//
//
//  Created by Илья Шаповалов on 01.04.2024.
//

import Foundation

public extension Sequence {
    
    /// Asynchronously mutates the collection by applying the closure to each element.
    /// Asynchronous operations are performed sequentially.
    /// - Parameter transform: A mapping asynchronous closure. `transform` accepts an
    ///                        element of this sequence as its parameter and returns a transformed
    ///                        value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this sequence.
    @inlinable
    func asyncMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
    
    @inlinable
    func asyncForEach(
        _ body: (Element) async throws -> Void
    ) async rethrows {
        for element in self { try await body(element) }
    }
    
    /// Returns the elements of the sequence, sorted using the given predicate returned by key path as the comparison between elements.
    ///
    /// An example of sorting a collection of songs by key property:
    ///
    ///     playlist.songs.sorted(by: \.name)
    ///     playlist.songs.sorted(by: \.dateAdded)
    ///     playlist.songs.sorted(by: \.ratings.worldWide)
    ///
    /// - Parameters:
    ///   - keyPath: A key path from the `Element` type to a specific resulting value type.
    ///   - ascending: A condition indicating how elements are sorted, in ascending order or not.
    @inlinable
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        ascending: Bool = true
    ) -> [Element] {
        sorted { lhs, rhs in
            if ascending {
                return lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
            }
            return lhs[keyPath: keyPath] > rhs[keyPath: keyPath]
        }
    }
    
    /// Creates a dictionary whose keys are the groupings returned by the
    /// given closure and whose values are arrays of the elements that returned
    /// each key.
    ///
    /// The arrays in the "values" position of the new dictionary each contain at
    /// least one element, with the elements in the same order as the source
    /// sequence.
    ///
    /// The following example declares an array of names, and then creates a
    /// dictionary from that array by grouping the names by first letter:
    ///
    ///     let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    ///     let studentsByLetter = students.grouped(by: \.first!)
    ///     // ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]]
    ///
    /// The new `studentsByLetter` dictionary has three entries, with students'
    /// names grouped by the keys `"E"`, `"K"`, and `"A"`.
    ///
    /// - Parameter keyPath: keyPath to property which become a key to array of grouped values
    @inlinable
    func grouped<T: Hashable>(
        by keyPath: KeyPath<Element, T>
    ) -> [T: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }
    
}

public extension Sequence where Element: Sendable {
    /// Asynchronously mutates the collection by applying the closure to each element.
    /// Asynchronous operations are performed concurrently.
    @inlinable
    func concurrentMap<T: Sendable>(
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        try await map { element in
            Task { try await transform(element) }
        }
        .asyncMap { try await $0.value }
    }
}

public extension Sequence where Element: Hashable {
    @inlinable func uniqued() -> Set<Element> { Set(self) }
}