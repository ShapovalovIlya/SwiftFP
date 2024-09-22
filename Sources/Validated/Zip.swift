//
//  Zip.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 22.09.2024.
//

import Foundation

@inlinable
public func zip<A,B,E>(
    _ lhs: Validated<A, E>,
    _ rhs: Validated<B, E>
) -> Validated<(A,B), E> where E: Error {
    lhs.zip(rhs)
}

@inlinable
public func zip<A,B,C,E>(
    _ lhs: Validated<A, E>,
    _ rhs: Validated<B, E>,
    using transform: (A, B) -> C
) -> Validated<C, E> where E: Error {
    lhs.zip(rhs, using: transform)
}

@inlinable
public func zip<A,B,C,E>(
    _ a: Validated<A, E>,
    _ b: Validated<B, E>,
    _ c: Validated<C, E>
) -> Validated<(A, B, C), E> where E: Error {
    zip(a, b).zip(c) { ($0.0, $0.1, $1) }
}

@inlinable
public func zip<A,B,C,D,E>(
    _ a: Validated<A, E>,
    _ b: Validated<B, E>,
    _ c: Validated<C, E>,
    using transform: (A, B, C) -> D
) -> Validated<D, E> where E: Error {
    zip(a, b, c).map(transform)
}
