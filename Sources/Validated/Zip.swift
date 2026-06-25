//
//  Zip.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 22.09.2024.
//

import Foundation

/// Zips two `Validated` instances into a single `Validated` containing a tuple.
///
/// If both are `.valid`, returns `.valid((lhs, rhs))`. If either is `.invalid`,
/// all errors are accumulated.
@inlinable
public func zip<A,B,E>(
    _ lhs: Validated<A, E>,
    _ rhs: Validated<B, E>
) -> Validated<(A,B), E> where E: Error {
    lhs.zip(rhs)
}

/// Zips two `Validated` instances and combines their results using a transform closure.
@inlinable
public func zip<A,B,C,E>(
    _ lhs: Validated<A, E>,
    _ rhs: Validated<B, E>,
    using transform: (A, B) -> C
) -> Validated<C, E> where E: Error {
    lhs.zip(rhs, using: transform)
}

/// Zips three `Validated` instances into a single `Validated` containing a tuple of three values.
@inlinable
public func zip<A,B,C,E>(
    _ a: Validated<A, E>,
    _ b: Validated<B, E>,
    _ c: Validated<C, E>
) -> Validated<(A, B, C), E> where E: Error {
    zip(a, b).zip(c) { ($0.0, $0.1, $1) }
}

/// Zips three `Validated` instances and combines their results using a transform closure.
@inlinable
public func zip<A,B,C,D,E>(
    _ a: Validated<A, E>,
    _ b: Validated<B, E>,
    _ c: Validated<C, E>,
    using transform: (A, B, C) -> D
) -> Validated<D, E> where E: Error {
    zip(a, b, c).map(transform)
}
