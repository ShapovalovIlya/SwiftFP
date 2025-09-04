//
//  LazySequence.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 05.09.2025.
//

import Foundation

public extension LazySequence {
    
    /// Returns a `LazyMapSequence` over this sequence.
    /// The elements of the result are computed lazily, each time they are accessed, by applying each function in the sequence to the given `value`.
    @inlinable
    func apply<A,B>(_ value: A) -> LazyMapSequence<Self, B> where Element == (A) -> B {
        self.lazy.map { $0(value) }
    }
}
