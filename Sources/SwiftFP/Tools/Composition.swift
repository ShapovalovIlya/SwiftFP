//
//  Composition.swift
//
//
//  Created by Илья Шаповалов on 16.08.2023.
//

precedencegroup CompositionPrecedence {
    associativity: left
}

infix operator >>>: CompositionPrecedence

public func >>> <A, B, C>(
    lhs: @escaping (A) -> B,
    rhs: @escaping (B) -> C
) -> (A) -> C {
    return { rhs(lhs($0)) }
}
