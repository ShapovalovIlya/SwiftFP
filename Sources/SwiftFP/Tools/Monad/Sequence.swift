//
//  Sequence.swift
//
//
//  Created by Илья Шаповалов on 01.04.2024.
//

import Foundation

extension Sequence {
    /// Асинхронно мутирует коллекцию, применяя кложур к каждому элементу.
    /// Асинхронные операции выполняются последовательно.
    @inlinable
    func asyncMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
    
    /// Асинхронно мутирует коллекцию, применяя кложур к каждому элементу.
    /// Асинхронные операции выполняются параллельно.
    @inlinable
    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }
        return try await tasks.asyncMap {
            try await $0.value
        }
    }
}
