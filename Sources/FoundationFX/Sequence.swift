//
//  Sequence.swift
//
//
//  Created by Илья Шаповалов on 01.04.2024.
//

import Foundation

public extension Sequence {
    /// An asynchronous sequence containing the same elements as this sequence,
    /// but on which operations, such as `map` and `filter`, are
    /// implemented asynchronously.
    @inlinable var asyncAdapter: AsyncAdapterSequence<Self> {
        AsyncAdapterSequence(self)
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
    
    @inlinable
    func set<T: Hashable>(
        of elementProvider: (Element) throws -> T
    ) rethrows -> Set<T> {
        try reduce(
            into: Set<T>(minimumCapacity: underestimatedCount)
        ) { partialResult, element in
            partialResult.insert(try elementProvider(element))
        }
    }
}

public extension Sequence where Element: Sendable {
    
    /// Asynchronously mutates the collection by applying the closure to each element.
    ///
    /// Because asynchronous operations are performed concurrently, returned array may contain transformation results
    /// in random order.
    ///
    /// - Parameter transform: A asynchronous closure accepts an element of the sequence as its parameter
    ///                        and returns a transformed value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this sequence.
    @inlinable
    func concurrentMap<T: Sendable>(
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: T.self, returning: [T].self) { group in
            self.forEach { element in
                group.addTask {
                    try await transform(element)
                }
            }
            return try await Array(group)
        }
    }
    
    /// Asynchronously mutates the collection by applying the closure to each element.
    ///
    /// Asynchronous operations are performed concurrently, but returned array contains elements in order.
    ///
    /// - Parameter transform: A asynchronous closure accepts an element of the sequence as its parameter
    ///                        and returns a transformed value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this sequence.
    @inlinable
    func asyncMap<T: Sendable>(
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { [pairs = enumerated()] group -> [T] in
            pairs.forEach { offset, element in
                group.addTask {
                    try await (offset, transform(element))
                }
            }
            let results = try await Dictionary(group, minimumCapacity: pairs.underestimatedCount)
            return pairs.compactMap { offset, _ in
                results[offset]
            }
        }
    }
    
    @inlinable
    func concurrentForEach(
        _ block: @escaping @Sendable (Element) async throws -> Void
    ) async rethrows {
        try await withThrowingTaskGroup(of: Void.self) { group in
            self.forEach { element in
                group.addTask { try await block(element) }
            }
            try await group.waitForAll()
        }
    }
}

public extension Sequence where Element: Hashable {
    @inlinable func uniqued() -> Set<Element> { Set(self) }
}
