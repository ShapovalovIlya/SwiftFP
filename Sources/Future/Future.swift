//
//  Future.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Foundation

public struct Future<Result> {
    @usableFromInline let expect: () async -> Result
    
    @inlinable
    public init(_ expect: @escaping () async -> Result) {
        self.expect = expect
    }
    
    @inlinable
    public static func pure(_ result: Result) -> Self {
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
        _ transform: @escaping (Result) async -> T
    ) -> Future<T> {
        Future<T> { await transform(self.run()) }
    }
    
    @inlinable
    public func flatMap<T>(
        _ transform: @escaping (Result) async -> Future<T>
    ) -> Future<T> {
        self.map(transform)
            .joined()
    }
}
