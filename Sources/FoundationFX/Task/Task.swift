//
//  Task.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 14.04.2026.
//

import Foundation

public extension Task {
    
    @inlinable
    @discardableResult
    func map<NewSuccess>(
        _ transform: sending @escaping (Success) async -> NewSuccess
    ) -> Task<NewSuccess, Failure> where Failure == Never {
        Task<NewSuccess, Failure> {
            return await transform(value)
        }
    }
    
    @inlinable
    @discardableResult
    func map<NewSuccess>(
        _ transform: sending @escaping (Success) async throws -> NewSuccess
    ) -> Task<NewSuccess, Error> {
        Task<NewSuccess, Error> {
            return try await transform(value)
        }
    }
    
    @inlinable
    @discardableResult
    func flatMap<NewSuccess>(
        _ transform: sending @escaping (Success) -> Task<NewSuccess, Failure>
    ) -> Task<NewSuccess, Error> {
        Task<NewSuccess, Error> {
            return try await transform(value).value
        }
    }

    @inlinable
    @discardableResult
    static func zip<each U>(
        _ first: Task<Success, Failure>,
        _ other: repeat Task<each U, Failure>
    ) -> Task<(Success, repeat each U), Error> {
        Task<(Success, repeat each U), Error> {
            try await (first.value, repeat (each other).value)
        }
    }
    
    @inlinable
    @discardableResult
    func zip<Other>(
        _ other: Task<Other, Failure>
    ) -> Task<(Success, Other), Error> {
        Task.zip(self, other)
    }
    
//    @inlinable
//    @discardableResult
//    static func sequence<S: Sequence>(
//        _ sequence: S
//    ) -> Task<[Success], Error> where S.Element == Task<Success, Failure>, S.Element: Sendable {
//        return Task<[Success], Error> { [sequence] in
//            try await sequence.asyncAdapter.reduce(into: [Success]()) { partialResult, child in
//                try await partialResult.append(child.value)
//            }
//        }
//    }
}
