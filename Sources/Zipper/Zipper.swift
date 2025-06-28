//
//  Zipper.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.09.2024.
//

import Foundation

/// A data structure for traversing and editing a collection with a movable cursor.
///
/// ‎`Zipper` provides a way to efficiently navigate and modify a collection (such as an array) by maintaining a cursor that points to the “current” element.
/// It allows you to access the elements before and after the cursor, move the cursor forward or backward, and perform transformations on the collection.
/// This is useful for scenarios like editors, undo/redo stacks, or any context where you need to focus on a particular element while retaining access to the rest of the collection.
///
/// ### Features:
/// - Access to previous, current, and next elements relative to the cursor.
/// - Move the cursor forward and backward.
/// - Map transformations over all elements while preserving the cursor position.
/// - Append new elements to the collection.
/// - Initialize from a single element, a sequence, or by specifying previous/current/next slices.
///
/// ### Example:
///```swift
/// // Create a zipper with three elements, focusing on the middle
/// let zipper = Zipper(previous: ["a"], current: "b", next: ["c", "d"])
/// print(zipper.current) // "b"
/// print(Array(zipper.previous)) // ["a"]
/// print(Array(zipper.next)) // ["c", "d"]
///
/// // Move the cursor forward
/// var mutableZipper = zipper
/// mutableZipper.forward()
/// print(mutableZipper.current) // "c"
///
/// // Map over all elements
/// let uppercased = zipper.mapZipper { $0.uppercased() }
/// print(uppercased.current) // "B"
/// ```
///
/// - Note: The cursor always points to a valid element. If initialized with an empty sequence, the initializer returns ‎`nil`.
public struct Zipper<Element> {
    public typealias SubSequence = [Element].SubSequence
    public typealias Index = [Element].Index
    
    /// The underlying array of all elements managed by the ‎`Zipper`.
    ///
    /// This property contains the complete collection of elements, including those before, at, and after the current cursor position.
    /// Use provided methods to manipulate the collection and maintain cursor integrity.
    ///
    /// - Note: The ‎`elements` array always contains at least one element, as a ‎`Zipper` cannot be empty./// - SeeAlso: ‎`current`, ‎`previous`, ‎`next
    public private(set) var elements: [Element]
    @usableFromInline var cursor: Int
    
    //MARK: - init(_:)
    private init(elements: [Element], cursor: Int) {
        self.elements = elements
        self.cursor = cursor
    }
    
    /// Creates a ‎`Zipper` from separate arrays of previous elements, a current element, and next elements.
    ///
    /// This initializer constructs a ‎`Zipper` by combining the ‎`previous` elements, the ‎`current` element, and the ‎`next` elements into a single collection.
    /// The cursor is positioned at the ‎`current` element, which follows all elements in ‎`previous`.
    ///
    /// - Parameters:
    ///   - previous: An array of elements that come before the current element.
    ///   - current: The element at the cursor position (the focus of the zipper).
    ///   - next: An array of elements that come after the current element.
    public init(previous: [Element], current: Element, next: [Element]) {
        self.elements = previous + CollectionOfOne(current) + next
        self.cursor = previous.count
    }
    
    /// Creates a ‎`Zipper` containing a single element.
    ///
    /// This initializer constructs a ‎`Zipper` with only one element, which becomes the current (and only) element in the collection.
    /// The cursor is positioned at the start (index 0).
    ///
    /// - Parameter single: The sole element to include in the zipper.
    public init(single: Element) {
        self.init(elements: [single], cursor: 0)
    }
    
    /// Creates a ‎`Zipper` from a sequence of elements, or returns ‎`nil` if the sequence is empty.
    ///
    /// This initializer constructs a ‎`Zipper` from any sequence of elements. The cursor is positioned at the first element.
    /// If the provided sequence is empty, the initializer returns ‎`nil`.
    ///
    /// - Parameter sequence: A sequence of elements to populate the zipper.
    /// - Returns: A ‎`Zipper` instance if the sequence is non-empty; otherwise, ‎`nil`.
    ///
    /// ### Example:
    ///```swift
    /// let zipper = Zipper([1, 2, 3])
    /// // zipper?.current == 1
    ///
    /// let emptyZipper = Zipper([Int]())
    /// // emptyZipper == nil
    ///```
    public init?<S>(_ sequence: S) where S: Sequence<Element> {
        let elements = Array(sequence)
        if elements.isEmpty { return nil }
        self.init(elements: elements, cursor: 0)
    }
    
    /// Creates a ‎`Zipper` from a sequence, setting the cursor to the first element that matches a given condition.
    ///
    /// This initializer constructs a ‎`Zipper` from any sequence of elements, positioning the cursor at the first element for which the ‎`setCurrent` closure returns ‎`true`.
    /// If no element matches the condition, or if the sequence is empty, the initializer returns ‎`nil`.
    ///
    /// - Parameters:
    ///   - sequence: A sequence of elements to populate the zipper.
    ///   - setCurrent: A closure that takes an element and returns ‎`true` if it should be the initial cursor position.
    /// - Returns: A ‎`Zipper` instance with the cursor set to the matching element, or ‎`nil` if no match is found.
    ///
    /// ### Example:
    ///```swift
    /// let zipper = Zipper([1, 2, 3, 4]) { $0 == 3 }
    /// // zipper?.current == 3
    ///
    /// let noMatch = Zipper([1, 2, 3, 4]) { $0 == 5 }
    /// // noMatch == nil
    ///```
    public init?<S>(
        _ sequence: S,
        setCurrent: (Element) -> Bool
    ) where S: Sequence<Element> {
        let elements = Array(sequence)
        guard let cursor = elements.firstIndex(where: setCurrent) else {
            return nil
        }
        self.init(elements: elements, cursor: cursor)
    }
    
    //MARK: - Public methods
    @inlinable
    public var indices: Range<Index> { elements.indices }
    
    @inlinable
    public var previous: SubSequence { elements.prefix(upTo: cursor) }
    
    @inlinable
    public var current: Element { elements[cursor] }
    
    @inlinable
    public var next: SubSequence {
        if cursor == elements.indices.last {
            return elements.suffix(0)
        }
        return elements.suffix(from: cursor + 1)
    }
    
    @inlinable
    public var count: Int { elements.count }
    
    @inlinable
    public var first: Element { elements.first! }
    
    @inlinable
    public var last: Element { elements.last! }
    
    @inlinable
    public var isAtEnd: Bool { indices.last == cursor }
    
    @inlinable
    public var isAtStart: Bool { elements.startIndex == cursor }
    
    @inlinable
    public func mapZipper<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> Zipper<T> {
        try Zipper<T>(
            previous: previous.map(transform),
            current: transform(current),
            next: next.map(transform)
        )
    }
    
    @inlinable
    public mutating func forward() {
        if indices.last == cursor { return }
        cursor = elements.index(after: cursor)
    }
    
    @inlinable
    public mutating func backward() {
        if startIndex == cursor { return }
        cursor = elements.index(before: cursor)
    }
    
    public mutating func append(_ newElement: Element) {
        elements.append(newElement)
    }
    
    public mutating func append(
        contentsOf sequence: some Sequence<Element>
    ) {
        elements.append(contentsOf: sequence)
    }
}

//MARK: - CaseIterable
public extension Zipper where Element: CaseIterable {
    @inlinable init?(variant: Element, setCurrent: (Element) -> Bool) {
        self.init(Element.allCases, setCurrent: setCurrent)
    }
    
    @inlinable init?(variant: Element) where Element: Equatable {
        self.init(variant: variant) { $0 == variant }
    }
}

//MARK: - Sequence
extension Zipper: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        elements.makeIterator()
    }
}

//MARK: - Collection
extension Zipper: Collection {
    
    @inlinable
    public var startIndex: Index {
        elements.startIndex
    }
    
    @inlinable
    public var endIndex: Index {
        elements.endIndex
    }
    
    public func index(after i: Index) -> Index {
        elements.index(after: i)
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        elements[bounds]
    }
    
    public subscript(position: Index) -> Element {
        get { elements[position] }
        set { elements[position] = newValue }
    }
}

extension Zipper: Equatable where Element: Equatable {
    
    public mutating func move(to predicate: (Element) -> Bool) {
        guard let destination = elements.firstIndex(where: predicate) else {
            return
        }
        cursor = destination
    }
}

extension Zipper: Hashable where Element: Hashable {}
extension Zipper: Sendable where Element: Sendable {}
