//
//  Effect.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 30.11.2024.
//

import Foundation

public struct Effect<Value> {
    @usableFromInline let work: () -> Value
    
    @inlinable
    public init(_ work: @escaping () -> Value) { self.work = work }
    
    @inlinable
    public func run() -> Value { work() }
    
    /// Returns the “purest” instance possible for the type
    @inlinable
    public static func pure(_ value: Value) -> Effect<Value> {
        Effect { value }
    }
    
    /// Joining a nested instance into a base one
    @inlinable
    public func joined<T>() -> Effect<T> where Value == Effect<T> {
        run()
    }
    
    @inlinable
    public func map<NewValue>(
        _ transform: @escaping (Value) -> NewValue
    ) -> Effect<NewValue> {
        Effect<NewValue> { transform(run()) }
    }
    
    @inlinable
    public func flatMap<NewValue>(
        _ transform: @escaping (Value) -> Effect<NewValue>
    ) -> Effect<NewValue> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func zip<Other>(
        _ other: Effect<Other>
    ) -> Effect<(Value, Other)> {
        Effect<(Value, Other)> { (self.run(), other.run()) }
    }
    
    @inlinable
    public func zip<Other, Result>(
        _ other: Effect<Other>,
        into: @escaping (Value, Other) -> Result
    ) -> Effect<Result> {
        self.zip(other)
            .map(into)
    }
}
