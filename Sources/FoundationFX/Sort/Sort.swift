//
//  Sort.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 17.05.2025.
//

import Foundation

public enum Sort {
    //MARK: - Order
    public enum Order: Hashable, Sendable, BitwiseCopyable {
        case ascending
        case descending
        
        @inlinable
        var inverted: Order {
            self == .ascending ? .descending : .ascending
        }
        
        @inlinable
        public func satisfy(_ result: ComparisonResult) -> Bool {
            switch self {
            case .ascending: result == .orderedAscending
            case .descending: result == .orderedDescending
            }
        }
    }

    //MARK: - Comparator
   public protocol Comparator<Element> {
        associatedtype Element
        
        var sortOrder: Sort.Order { get }
        func compare(_ lhs: Element, _ rhs: Element) -> ComparisonResult
    }
}

@available(macOS 12.0, *)
extension SortOrder {
    @inlinable init(_ sortOrder: Sort.Order) {
        switch sortOrder {
        case .ascending: self = .forward
        case .descending: self = .reverse
        }
    }
}

@available(macOS 12.0, *)
extension Sort.Order {
    @inlinable init(_ sortOrder: SortOrder) {
        switch sortOrder {
        case .forward: self = .ascending
        case .reverse: self = .descending
        }
    }
}
