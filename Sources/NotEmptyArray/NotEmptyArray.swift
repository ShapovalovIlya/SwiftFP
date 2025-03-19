//
//  NotEmptyArray.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation

extension Array {
    @inlinable
    func element(at index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

public struct NotEmptyArray<Element> {
    //MARK: - Properties
    public private(set) var head: Element
    public private(set) var tail: [Element]
    
    //MARK: - init(_:)
    public init(head: Element, tail: [Element]) {
        self.head = head
        self.tail = tail
    }
    
    @inlinable
    public init(single: Element) {
        self.init(head: single, tail: [])
    }
    
    @inlinable
    public init?<S>(_ sequence: S) where S: Sequence<Element> {
        var iterator = sequence.makeIterator()
        guard let head = iterator.next() else { return nil }
        var tail = [Element]()
        while let element = iterator.next() {
            tail.append(element)
        }
        self.init(head: head, tail: tail)
    }
    
    //MARK: - Methods
    @inlinable
    public var array: [Element] { CollectionOfOne(head) + tail }
    
    /// Returns an `NotEmptyArray` containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure. transform accepts an element of this sequence as its parameter and
    ///                        returns a transformed value of the same or of a different type.
    /// - Returns: An `NotEmptyArray` containing the transformed elements of this sequence.
    @inlinable
    public func map<T, E>(
        _ transform: (Element) throws(E) -> T
    ) rethrows -> NotEmptyArray<T> where E: Error {
        NotEmptyArray<T>(
            head: try transform(head),
            tail: try tail.map(transform)
        )
    }
    
    /// Adds the elements of a sequence to the end of the `NotEmptyArray`.
    /// - Parameter sequence: The elements to append to the array.
    public mutating func append(contentsOf sequence: some Sequence<Element>) {
        tail.append(contentsOf: sequence)
    }
    
    /// Adds a new element at the end of the `NotEmptyArray`.
    /// - Parameter element: The element to append to the array.
    public mutating func append(_ element: Element) {
        tail.append(element)
    }
    
    @inlinable
    public func element(at index: Int) -> Element? {
        index == .zero ? head : tail.element(at: index - 1)
    }
}

public extension NotEmptyArray {
    //MARK: - Arithmetics
    @inlinable
    static func += (lhs: inout Self, rhs: Self) -> Self {
        lhs.append(contentsOf: rhs)
        return lhs
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        var sum = lhs
        return sum += rhs
    }
    
}

//MARK: - Sequence
extension NotEmptyArray: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        array.makeIterator()
    }
}

extension NotEmptyArray: CustomStringConvertible {
    @inlinable
    public var description: String {
        let summ = CollectionOfOne(head) + tail
        return summ.description
    }
}

extension NotEmptyArray: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self, unlabeledChildren: array, displayStyle: .collection)
    }
}

extension NotEmptyArray: Equatable where Element: Equatable {}
extension NotEmptyArray: Hashable where Element: Hashable {}
extension NotEmptyArray: Sendable where Element: Sendable {}
