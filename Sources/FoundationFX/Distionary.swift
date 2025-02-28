//
//  Distionary.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.03.2025.
//

import Foundation

public extension Dictionary {
    @inlinable
    init(@Array<(Key, Value)>.Builder _ build: () -> [(Key, Value)]) {
        self.init(build(), uniquingKeysWith: { $1 })
    }
    
    @inlinable
    init<S: AsyncSequence>(
        _ s: S
    ) async rethrows where S.Element == (Key, Value) {
        self = try await s.reduce(into: [Key: Value]()) { partialResult, pair in
            partialResult[pair.0] = pair.1
        }
    }
}
