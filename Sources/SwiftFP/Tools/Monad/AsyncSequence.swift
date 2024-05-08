//
//  AsyncSequence.swift
//
//
//  Created by Илья Шаповалов on 08.04.2024.
//

import Foundation

public extension AsyncSequence {
    
    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    /// - Parameter body: A asynchronous closure that takes an element of the sequence as a parameter.
    @inlinable
    func forEach(_ body: (Self.Element) async throws -> Void) async rethrows {
        for try await element in self {
            try await body(element)
        }
    }
    
    
    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    @inlinable
    func forEach(_ body: (Self.Element) throws -> Void) async rethrows {
        for try await element in self {
            try body(element)
        }
    }
    
}
