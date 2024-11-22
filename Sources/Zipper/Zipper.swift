//
//  Zipper.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.09.2024.
//

import Foundation

public struct Zipper<Element> {
    @usableFromInline var _previous: [Element]
    @usableFromInline var _current: Element
    @usableFromInline var _next: [Element]
    
    //MARK: - init(_:)
    @inlinable
    public init(previous: [Element], current: Element, next: [Element]) {
        self._previous = previous
        self._current = current
        self._next = next
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
    @inlinable public var previous: [Element] { _previous }
    @inlinable public var current: Element { _current }
    @inlinable public var next: [Element] { _next }
    
    @inlinable
    public var count: Int { previous.count + 1 + next.count }
    
    @inlinable
    public var array: [Element] {
        var temp = _previous
        temp += CollectionOfOne(_current)
        temp += _next
        return temp
    }
    
    @inlinable
    public var first: Element {
        if let first = _previous.first { return first }
        return _current
    }
    
    @inlinable
    public var last: Element {
        if let last = _next.last { return last }
        return _current
    }
    
    @inlinable
    public func mapZipper<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> Zipper<T> {
        try Zipper<T>(
            previous: _previous.map(transform),
            current: transform(_current),
            next: _next.map(transform)
        )
    }
    
    @inlinable
    public mutating func forward() {
        if _next.isEmpty { return }
        _previous.append(_current)
        _current = _next.removeFirst()
    }
    
    @inlinable
    public mutating func backward() {
        if _previous.isEmpty { return }
        _next.insert(_current, at: _next.startIndex)
        _current = _previous.removeLast()
    }
    
    @inlinable
    public mutating func append(_ newElement: Element) {
        _next.append(newElement)
    }
    
    @inlinable
    public mutating func append(
        contentsOf sequence: some Sequence<Element>
    ) {
        _next.append(contentsOf: sequence)
    }
}

//MARK: - Sequence
extension Zipper: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        array.makeIterator()
    }
}

extension Zipper: Equatable where Element: Equatable {
    @inlinable
    public mutating func move(to predicate: (Element) -> Bool) {
        if predicate(_current) { return }
        if let index = _previous.firstIndex(where: predicate) {
            let suffIndex = _previous.index(after: index)
            var suffix = _previous.suffix(from: suffIndex)
            _previous.removeSubrange(suffIndex..<_previous.endIndex)
            suffix.append(_current)
            _current = _previous.remove(at: index)
            _next.insert(contentsOf: suffix, at: _next.startIndex)
            return
        }
        guard let index = _next.firstIndex(where: predicate) else {
            return
        }
        var prefix = _next.prefix(through: index)
        if prefix.isEmpty { return }
        _previous.append(_current)
        _current = prefix.removeLast()
        _previous.append(contentsOf: prefix)
    }
}

extension Zipper: Hashable where Element: Hashable {}
extension Zipper: Sendable where Element: Sendable {}
