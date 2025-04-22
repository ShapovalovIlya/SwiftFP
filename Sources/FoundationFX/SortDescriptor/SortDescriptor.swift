//
//  SortDescriptor.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 13.04.2025.
//

import Foundation

public enum Sort {
    //MARK: - Comparator
    public typealias Comparator<Element> = (Element, Element) -> ComparisonResult
    
    //MARK: - Order
    public enum Order {
        case ascending
        case descending
        
        @inlinable
        var inverted: Order {
            self == .ascending ? .descending : .ascending
        }
        
        @inlinable
        public func isEqual(to result: ComparisonResult) -> Bool {
            switch self {
            case .ascending: result == .orderedAscending
            case .descending: result == .orderedDescending
            }
        }
    }
    
    //MARK: - Descriptor
    public struct Descriptor<Element> {
        @usableFromInline let order: Sort.Order
        @usableFromInline let comparator: Comparator<Element>
        
        @inlinable
        public init(
            _ order: Sort.Order,
            comparator: @escaping Sort.Comparator<Element>
        ) {
            self.order = order
            self.comparator = comparator
        }
        
        @inlinable
        public init<C: Comparable>(
            _ order: Sort.Order,
            lens: @escaping (Element) -> C
        ) {
            self.order = order
            self.comparator = { lRoot, rRoor in
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
    func compare(_ lhs: Element, _ rhs: Element) -> Bool {
        order.isEqual(to: comparator(lhs, rhs))
    }
    
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
    static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> Self {
        Sort.Descriptor(.ascending, lens: { $0[keyPath: keyPath] })
    }
    
    @inlinable
    static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> Self {
        Sort.Descriptor(.descending, lens: { $0[keyPath: keyPath] })
    }

}

//MARK: - Sequence
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
    
    /// Returns the elements of the sequence, sorted using the given predicate returned by key path
    /// as the comparison between elements.
    ///
    /// An example of sorting a collection of songs by key property:
    ///
    ///```swift
    /// playlist.songs.sorted(by: \.name)
    /// playlist.songs.sorted(by: \.dateAdded)
    /// playlist.songs.sorted(by: \.ratings.worldWide)
    ///```
    ///
    /// - Parameters:
    ///   - keyPath: A key path from the `Element` type to a specific resulting value type.
    ///   - ascending: A condition indicating how elements are sorted, in ascending order or not.
    @inlinable
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        ascending: Bool = true
    ) -> [Element] {
        switch ascending {
        case true: return sorted(by: keyPath, using: <)
        case false: return sorted(by: keyPath, using: >)
        }
    }
    
    @inlinable
    func sorted(by comparators: [(Element, Element) -> Bool]) -> [Element] {
        sorted { lhs, rhs in
            comparators.first { $0(lhs, rhs) } != nil
        }
    }
    
    @inlinable
    func sorted(using descriptors: [Sort.Descriptor<Element>]) -> [Element] {
        sorted(by: descriptors.map { $0.compare })
    }
    
    @inlinable
    func sorted(using descriptors: Sort.Descriptor<Element>...) -> [Element] {
        sorted(using: descriptors)
    }
}
