//
//  AsyncSequence.swift
//
//
//  Created by Илья Шаповалов on 08.04.2024.
//

import Foundation

public extension AsyncSequence {
    @inlinable
    func forAwaitEach(_ body: (Element) throws -> Void) async rethrows {
        for try await element in self {
            try body(element)
        }
    }
}
