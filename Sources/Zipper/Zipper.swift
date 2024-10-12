//
//  Zipper.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.09.2024.
//

import Foundation

public struct Zipper<Element> {
    public private(set) var previous: [Element]
    public private(set) var current: Element
    public private(set) var next: [Element]
    
    //MARK: - init(_:)
    public init(previous: [Element], current: Element, next: [Element]) {
        self.previous = previous
        self.current = current
        self.next = next
    }
    
    @inlinable
    public init?<S>(_ sequence: S) where S: Sequence<Element> {
        var iterator = sequence.makeIterator()
        guard let first = iterator.next() else { return nil }
        var other = [Element]()
        while let element = iterator.next() {
            other.append(element)
        }
        self.init(previous: [], current: first, next: other)
    }
    
    @inlinable
    public init?<S>(
        _ sequence: S,
        setCurrent: (Element) -> Bool
    ) where S: Sequence<Element> {
        var iterator = sequence.makeIterator()
        
        var current: Element?
        var previous = [Element]()
        var next = [Element]()
        
        while let element = iterator.next() {
            if current != nil {
                next.append(element)
                continue
            }
            if setCurrent(element) {
                current = element
                continue
            }
            previous.append(element)
        }
        
        guard let current else { return nil }
        self.init(previous: previous, current: current, next: next)
    }
    
    //MARK: - Public methods
    @inlinable
    public var count: Int { previous.count + 1 + next.count }
    
    @inlinable
    public var array: [Element] {
        var temp = previous
        temp += CollectionOfOne(current)
        temp += next
        return temp
    }
    
    @inlinable
    public var first: Element {
        if let first = previous.first { return first }
        return current
    }
    
    @inlinable
    public var last: Element {
        if let last = next.last { return last }
        return current
    }
    
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
}

//MARK: - Sequence
extension Zipper: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        array.makeIterator()
    }
}

extension Zipper: Equatable where Element: Equatable {}
extension Zipper: Hashable where Element: Hashable {}
extension Zipper: Sendable where Element: Sendable {}
