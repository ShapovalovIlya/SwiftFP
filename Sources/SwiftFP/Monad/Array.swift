//
//  Array.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.08.2024.
//

import Foundation

public extension Dictionary {
    init(@Array<(Key, Value)>.Builder _ build: () -> [(Key, Value)]) {
        self.init(build(), uniquingKeysWith: { $1 })
    }
}

public extension Set {
    init(@Array<Element>.Builder _ build: () -> [Element]) {
        self = Set(build())
    }
}

public extension Array {
    //MARK: - init(_:)
    init(@Builder _ build: () throws -> [Element]) rethrows { self = try build() }
    
    //MARK: - Builder
    @resultBuilder
    enum Builder {
        @inlinable
        public static func buildExpression(_ expression: Void) -> [Element] {
            []
        }
        
        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [expression]
        }
        
        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            expression
        }
        
        @inlinable
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            components.flatMap { $0 }
        }
        
        @inlinable
        public static func buildBlock(_ components: [Element]...) -> [Element] {
            buildArray(components)
        }
        
        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }
    
        @inlinable
        public static func buildEither(first component: [Element]) -> [Element] {
            component
        }
        
        @inlinable
        public static func buildEither(second component: [Element]) -> [Element] {
            component
        }
    }
}