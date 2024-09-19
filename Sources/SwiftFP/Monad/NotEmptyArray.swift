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
    public init?(_ array: [Element]) {
        guard let head = array.first else { return nil }
        self.init(head: head, tail: .init(array.suffix(from: 1)))
    }
    
    //MARK: - Methods
    public var array: [Element] { CollectionOfOne(head) + tail }
    
    @inlinable
    public func mapNotEmpty<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> NotEmptyArray<T> {
        NotEmptyArray<T>(
            head: try transform(head),
            tail: try tail.map(transform)
        )
    }
    
    
}

//MARK: - Sequence
extension NotEmptyArray: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        array.makeIterator()
    }
}
