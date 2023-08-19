//
//  Compose.swift
//
//
//  Created by Илья Шаповалов on 16.08.2023.
//

public func compose<A,B,C>(
    _ f: @escaping (A) throws -> B,
    _ g: @escaping (B) throws -> C
) rethrows -> (A) throws -> C {
    { try g(f($0)) }
}

public func compose<A,B,C,D>(
    _ f: @escaping (A) throws -> B,
    _ g: @escaping (B) throws -> C,
    _ h: @escaping (C) throws -> D
) rethrows -> (A) throws -> D {
    { try h(g(f($0))) }
}
