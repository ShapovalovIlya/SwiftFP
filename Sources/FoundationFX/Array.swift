//
//  Array.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.08.2024.
//

import Foundation

public typealias BuilderOf<T> = Array<T>.Builder

public extension Set {
    @available(*, deprecated, message: "Use Set.build instead")
    @inlinable
    init(@Array<Element>.Builder _ build: () -> [Element]) {
        self = Set(build())
    }
    
    @inlinable
    static func build(@BuilderOf<Element> _ build: () throws -> [Element]) rethrows -> Self {
        Set(try build())
    }
}

public extension Array {
    //MARK: - init(_:)
    
    @available(*, deprecated, message: "Use Array.build instead")
    @inlinable
    init(@Builder _ build: () throws -> [Element]) rethrows { self = try build() }
    
    @inlinable
    init<S: AsyncSequence>(_ s: S) async rethrows where S.Element == Element {
        self = try await s.reduce(into: [Element]()) { $0.append($1) }
    }
    
    @inlinable
    static func build(@Builder _ build: () throws -> [Element]) rethrows -> Self {
        try build()
    }
    
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
            components.flatMap(\.self)
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
