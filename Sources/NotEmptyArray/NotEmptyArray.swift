//
//  NotEmptyArray.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation

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
    public var array: [Element] { CollectionOfOne(head) + tail }
    
    @inlinable
    public func mapNotEmpty<T, E>(
        _ transform: (Element) throws(E) -> T
    ) rethrows -> NotEmptyArray<T> where E: Error {
        NotEmptyArray<T>(
            head: try transform(head),
            tail: try tail.map(transform)
        )
    }
        
    public mutating func append(contentsOf other: Self) {
        tail.append(contentsOf: other.array)
    }
    
    public mutating func append(_ element: Element) {
        tail.append(element)
    }
    
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        result.append(contentsOf: rhs)
        return result
    }
}

//MARK: - Sequence
extension NotEmptyArray: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        array.makeIterator()
    }
}

extension NotEmptyArray: Equatable where Element: Equatable {}
extension NotEmptyArray: Hashable where Element: Hashable {}
extension NotEmptyArray: Sendable where Element: Sendable {}
