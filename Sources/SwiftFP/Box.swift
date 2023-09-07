//
//  Box.swift
//  
//
//  Created by Илья Шаповалов on 01.09.2023.
//

import Foundation

public struct Box<T> {
    public let value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func map<U>(_ transform: (T) throws -> U) rethrows -> Box<U> {
        Box<U>(try transform(self.value))
    }
    
    public func flatMap<U>(_ transform: (T) throws -> Box<U>) rethrows -> Box<U> {
        try transform(self.value)
    }
    
    public func apply<U>(_ transform: Box<(T) -> U>) -> Box<U> {
        Box<U>(transform.value(self.value))
    }
}
