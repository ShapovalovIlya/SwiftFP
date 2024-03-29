//
//  Box.swift
//  
//
//  Created by Илья Шаповалов on 01.09.2023.
//

import Foundation

/// Monad structure that performs `map`, `flatMap` and `apply` to wrapped value.
public struct Box<T> {
    public let value: T
    
    @inlinable
    public init(_ value: T) {
        self.value = value
    }
    
    @inlinable
    public func map<U>(_ transform: (T) throws -> U) rethrows -> Box<U> {
        Box<U>(try transform(self.value))
    }
    
    @inlinable
    public func flatMap<U>(_ transform: (T) throws -> Box<U>) rethrows -> Box<U> {
        try transform(self.value)
    }
    
    @inlinable
    public func apply<U>(_ transform: Box<(T) -> U>) -> Box<U> {
        Box<U>(transform.value(self.value))
    }
}
