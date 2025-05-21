//
//  FilterPredicate.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.05.2025.
//

import Foundation

public struct FilterPredicate<Input> {
    @usableFromInline let validate: (Input) -> Bool
    
    @inlinable
    init(_ validate: @escaping (Input) -> Bool) {
        self.validate = validate
    }
    
    @inlinable
    static func pure(_ value: Bool) -> FilterPredicate<Input> {
        FilterPredicate<Input> { _ in value }
    }
    
    @inlinable
    func satisfied(_ input: Input) -> Bool {
        validate(input)
    }
    
    @inlinable
    var not: FilterPredicate<Input> {
        FilterPredicate<Input> { !self.satisfied($0) }
    }
    
    @inlinable
    func and(_ isSatisfied: @escaping (Input) -> Bool) -> FilterPredicate<Input> {
        FilterPredicate<Input> { input in
            self.satisfied(input) && isSatisfied(input)
        }
    }
    
    @inlinable
    func or(_ isSatisfied: @escaping (Input) -> Bool) -> FilterPredicate<Input> {
        FilterPredicate<Input> { input in
            self.satisfied(input) || isSatisfied(input)
        }
    }
    
    @inlinable
    func zip(
        _ other: FilterPredicate<Input>,
        using combinator: @escaping (Bool, Bool) -> Bool
    ) -> FilterPredicate<Input> {
        FilterPredicate<Input> { input in
            let lhs = self.satisfied(input)
            let rhs = other.satisfied(input)
            return combinator(lhs, rhs)
        }
    }
    
    @inlinable
    func and(_ other: FilterPredicate<Input>) -> FilterPredicate<Input> {
        zip(other, using: { $0 && $1 })
    }
    
    @inlinable
    func or(_ other: FilterPredicate<Input>) -> FilterPredicate<Input> {
        zip(other, using: { $0 || $1 })
    }
    
    @inlinable
    func not(_ other: FilterPredicate<Input>) -> FilterPredicate<Input> {
        zip(other.not, using: { $0 && $1 })
    }
    
    @inlinable
    static func && (
        lhs: FilterPredicate<Input>,
        rhs: FilterPredicate<Input>
    ) -> FilterPredicate<Input> {
        lhs.and(rhs)
    }
    
    @inlinable
    static func || (
        lhs: FilterPredicate<Input>,
        rhs: FilterPredicate<Input>
    ) -> FilterPredicate<Input> {
        lhs.or(rhs)
    }
}

extension Sequence {
    @inlinable
    func filter(_ predicate: FilterPredicate<Element>) -> [Element] {
        filter(predicate.satisfied)
    }
}

extension LazySequenceProtocol {
    @inlinable
    func filter(_ predicate: FilterPredicate<Element>) -> LazyFilterSequence<Elements> {
        self.filter(predicate.satisfied)
    }
}

extension LazyCollectionProtocol {
    @inlinable
    func filter(_ predicate: FilterPredicate<Element>) -> LazyFilterCollection<Elements> {
        self.filter(predicate.satisfied)
    }
}
