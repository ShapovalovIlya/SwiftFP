//
//  SortDescriptor.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 13.04.2025.
//

import Foundation

extension Sort {
    //MARK: - Descriptor
    public struct Descriptor<Element>: Comparator {
        public let sortOrder: Sort.Order
        @usableFromInline let comparator: (Element, Element) -> ComparisonResult
        
        @inlinable
        public func compare(_ lhs: Element, _ rhs: Element) -> ComparisonResult {
            comparator(lhs, rhs)
        }
        
        @inlinable
        public init(
            _ order: Sort.Order = .ascending,
            comparator: @escaping (Element, Element) -> ComparisonResult
        ) {
            self.sortOrder = order
            self.comparator = comparator
        }
        
        @inlinable
        public init<C: Comparable>(
            _ order: Sort.Order = .ascending,
            lens: @escaping (Element) -> C
        ) {
            self.init(order) { lRoot, rRoor in
                let lhs = lens(lRoot)
                let rhs = lens(rRoor)
                
                if lhs == rhs { return .orderedSame }
                
                return lhs < rhs
                ? .orderedAscending
                : .orderedDescending
            }
        }
    }
}

public extension Sort.Descriptor {
    
    @inlinable
    static func keyPath<T: Comparable>(
        _ keyPath: KeyPath<Element, T>,
        order: Sort.Order = .ascending
    ) -> Self {
        Sort.Descriptor(order) { lRoot, rRoor in
            let lhs = lRoot[keyPath: keyPath]
            let rhs = rRoor[keyPath: keyPath]
            
            if lhs == rhs { return .orderedSame }
            
            return lhs < rhs
            ? .orderedAscending
            : .orderedDescending
        }
    }
    
    @inlinable
    static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T> & Sendable) -> Self {
        Sort.Descriptor(.ascending, lens: { $0[keyPath: keyPath] })
    }
    
    @inlinable
    static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T> & Sendable) -> Self {
        Sort.Descriptor(.descending, lens: { $0[keyPath: keyPath] })
    }

}

//MARK: - Sequence

public extension Sequence {
    
    @inlinable
    func sorted<C: Sort.Comparator>(
        by comparator: C
    ) -> [Element] where Self.Element == C.Element {
        sorted { lhs, rhs in
            let result = comparator.compare(lhs, rhs)
            return comparator.sortOrder.satisfy(result)
        }
    }
    
    @inlinable
    func sorted<C: Sort.Comparator>(
        using comparators: [C]
    ) -> [Element] where Self.Element == C.Element {
        sorted { lhs, rhs in
            comparators.first {
                let result = $0.compare(lhs, rhs)
                return $0.sortOrder.satisfy(result)
            } != nil
        }
    }
}
