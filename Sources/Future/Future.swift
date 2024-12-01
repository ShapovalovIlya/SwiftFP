//
//  Future.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Foundation

@frozen
public struct Future<Result>: Sendable {
    @usableFromInline let expect: @Sendable () async -> Result
    
    @inlinable
    public init(_ expect: @escaping @Sendable () async -> Result) {
        self.expect = expect
    }
    
    @inlinable
    public static func pure(
        _ result: Result
    ) -> Self where Result: Sendable {
        Future { result }
    }
    
    @inlinable
    public func run() async -> Result { await expect() }
    
    @inlinable
    public func joined<T>() -> Future<T> where Result == Future<T> {
        Future<T> { await self.run().run() }
    }
    
    @inlinable
    public func map<T>(
        _ transform: @escaping @Sendable (Result) async -> T
    ) -> Future<T> {
        Future<T> { await transform(self.run()) }
    }
    
    @inlinable
    public func flatMap<T>(
        _ transform: @escaping @Sendable (Result) async -> Future<T>
    ) -> Future<T> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func zip<Other>(
        _ other: Future<Other>
    ) -> Future<(Result, Other)> {
        Future<(Result, Other)> {
            async let lhs = self.run()
            async let rhs = other.run()
            return await (lhs, rhs)
        }
    }
    
    @inlinable
    public func zip<Other, NewResult>(
        _ other: Future<Other>,
        into combine: @escaping @Sendable (Result, Other) async -> NewResult
    ) -> Future<NewResult> {
        self.zip(other)
            .map(combine)
    }
}
