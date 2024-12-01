//
//  State.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Foundation

public struct State<Environment, Value> {
    public typealias Reducer = (Environment) -> (environment: Environment, value: Value)
    
    @usableFromInline let call: Reducer
    
    @inlinable
    public init(_ call: @escaping (Environment) -> (Environment, Value)) {
        self.call = call
    }
    
    @inlinable
    public func reduce(
        _ environment: Environment
    ) -> (environment: Environment, value: Value) {
        call(environment)
    }
    
    /// Returns the “purest” instance possible for the type
    @inlinable
    public static func pure(_ value: Value) -> Self {
        State { env in (env, value) }
    }
    
    @inlinable
    public func joined<T>() -> State<Environment, T> where Value == State<Environment, T> {
        State<Environment, T> { env in
            let (newEnv, sub) = self.reduce(env)
            return sub.reduce(newEnv)
        }
    }
    
    @inlinable
    public func map<T>(
        _ transform: @escaping (Value) -> T
    ) -> State<Environment, T> {
        State<Environment, T> { env in
            let (newEnv, val) = self.reduce(env)
            return (newEnv, transform(val))
        }
    }
    
    @inlinable
    public func flatMap<T>(
        _ transform: @escaping (Value) -> State<Environment, T>
    ) -> State<Environment, T> {
        self.map(transform)
            .joined()
    }
}
