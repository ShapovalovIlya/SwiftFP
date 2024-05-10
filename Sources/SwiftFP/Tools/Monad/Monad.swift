//
//  Monad.swift
//
//
//  Created by Илья Шаповалов on 01.09.2023.
//

import Foundation

/// Monad structure that performs `map`, `flatMap` and `apply` to wrapped value.
public struct Monad<T> {
    public let value: T
    
    @inlinable
    public init(_ value: T) {
        self.value = value
    }
    
    @inlinable
    public func map<U>(_ transform: (T) throws -> U) rethrows -> Monad<U> {
        Monad<U>(try transform(self.value))
    }
    
    @inlinable
    public func flatMap<U>(_ transform: (T) throws -> Monad<U>) rethrows -> Monad<U> {
        try transform(self.value)
    }
    
    @inlinable
    public func apply<U>(_ transform: Monad<(T) -> U>) -> Monad<U> {
        Monad<U>(transform.value(self.value))
    }
}
