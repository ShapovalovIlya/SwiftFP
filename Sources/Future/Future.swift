//
//  Future.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Foundation

/// The Future monad is a pattern to handle asynchronous function as object.
///
/// The `Future` monad is basically a container for a value which is either available now or will be available in the near future.
/// You can make chains of Futures with `.map(_:)` and `.flatMap(_:)` that will wait for the Future value to be resolved
/// before executing the next piece of code that depends on the value being resolved first.
///
/// `Future` is "lazy" monad. All computations will be performed only after calling instance method `.run()`.
@frozen
public struct Future<Value>: Sendable {
    @usableFromInline let expect: @Sendable () async -> Value
    
    //MARK: - init(_:)
    @inlinable
    public init(_ expect: @escaping @Sendable () async -> Value) {
        self.expect = expect
    }
    
    //MARK: - pure(_:)
    @inlinable
    public static func pure(
        _ value: Value
    ) -> Self where Value: Sendable {
        Future { value }
    }
    
    @inlinable
    public func run() async -> Value { await expect() }
    
    @inlinable
    public func joined<T>() -> Future<T> where Value == Future<T> {
        Future<T> { await self.run().run() }
    }
    
    @inlinable
    public func map<T>(
        _ transform: @escaping @Sendable (Value) async -> T
    ) -> Future<T> {
        Future<T> { await transform(self.run()) }
    }
    
    @inlinable
    public func flatMap<T>(
        _ transform: @escaping @Sendable (Value) async -> Future<T>
    ) -> Future<T> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func zip<Other>(
        _ other: Future<Other>
    ) -> Future<(Value, Other)> {
        Future<(Value, Other)> {
            async let lhs = self.run()
            async let rhs = other.run()
            return await (lhs, rhs)
        }
    }
    
    @inlinable
    public func zip<Other, NewResult>(
        _ other: Future<Other>,
        into combine: @escaping @Sendable (Value, Other) async -> NewResult
    ) -> Future<NewResult> {
        self.zip(other)
            .map(combine)
    }
}
