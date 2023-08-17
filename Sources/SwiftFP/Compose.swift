//
//  Compose.swift
//
//
//  Created by Илья Шаповалов on 16.08.2023.
//

public func compose<A,B,C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C
) -> (A) -> C {
    { g(f($0)) }
}

public func compose<A,B,C,D>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C,
    _ h: @escaping (C) -> D
) -> (A) -> D {
    { h(g(f($0))) }
}

