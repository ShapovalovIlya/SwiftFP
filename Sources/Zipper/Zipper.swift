//
//  Zipper.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.09.2024.
//

import Foundation

public struct Zipper<Element> {
    public typealias SubSequence = [Element].SubSequence
    public typealias Index = [Element].Index
    
    public private(set) var elements: [Element]
    @usableFromInline var cursor: Int
    
    //MARK: - init(_:)
    private init(elements: [Element], cursor: Int) {
        self.elements = elements
        self.cursor = cursor
    }
    
    public init(previous: [Element], current: Element, next: [Element]) {
        self.elements = previous + CollectionOfOne(current) + next
        self.cursor = previous.count
    }
    
    public init(single: Element) {
        self.init(elements: [single], cursor: 0)
    }
    
    public init?<S>(_ sequence: S) where S: Sequence<Element> {
        let elements = Array(sequence)
        if elements.isEmpty { return nil }
        self.init(elements: elements, cursor: 0)
    }
    
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
