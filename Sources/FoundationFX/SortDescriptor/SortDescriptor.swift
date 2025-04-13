//
//  SortDescriptor.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 13.04.2025.
//

import Foundation

public enum SortOrder {
    case ascending
    case descending
}

public struct SortDescriptor<Element> {
    public typealias Comparator = (Element, Element) -> ComparisonResult
    
    public let comparator: Comparator
    
    @inlinable
    public init(_ comparator: @escaping Comparator) {
        self.comparator = comparator
    }
}

public extension SortDescriptor {
    @inlinable
    static func keyPath<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> Self {
        Self { lRoot, rRoor in
            let lhs = lRoot[keyPath: keyPath]
            let rhs = rRoor[keyPath: keyPath]
            
            if lhs == rhs { return .orderedSame }
            
            return lhs < rhs
            ? .orderedAscending
            : .orderedDescending
        }
    }
}

public extension Sequence {
    @inlinable
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) throws -> Bool
    ) rethrows -> [Element] {
        try sorted { lhs, rhs in
            try comparator(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        }
    }
    
    @inlinable
    func sorted(
        using descriptors: [SortDescriptor<Element>],
        order: SortOrder = .ascending
    ) -> [Element] {
        sorted { lhs, rhs in
            for descriptor in descriptors {
                switch descriptor.comparator(lhs, rhs) {
                case .orderedAscending:
                    return order == .ascending
                    
                case .orderedDescending:
                    return order == .descending
                    
                case .orderedSame:
                    continue
                }
            }
            return false
        }
    }
    
    @inlinable
    func sorted(
        using descriptors: SortDescriptor<Element>...,
        order: SortOrder = .ascending
    ) -> [Element] {
        sorted(using: descriptors, order: order)
    }
}
