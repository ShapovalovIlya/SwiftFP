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
}
