//
//  KeyPathExtensions.swift
//  Messanger
//
//  Created by Шаповалов Илья on 24.07.2024.
//  Copyright © 2024 insystem. All rights reserved.
//

import Foundation

/// Overloading the built-in prefix operator `!`, which allows this operator to be applied to any `Bool` key path,
/// to turn it into a function that inverts (or flips) its value.
///
///   Example of inverting `keyPath` in the `.filter(_:)` function:
///
///       let unreadArticles = articles.filter(!\.isRead)
///
@inlinable
public prefix func !<T>(keyPath: KeyPath<T, Bool>) -> (T) -> Bool {
    { !$0[keyPath: keyPath] }
}

/// Overloading the built-in operator `==`, which allows you to apply it to any `Equatable` key path
///
///    An example of comparing the `keyPath` property in the `.filter(_:)` function:
///
///        let fullLengthArticles = articles.filter(\.category == .fullLength)
///
@inlinable
public func ==<T, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (T) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

/// Overloading the built-in operator `!=`,
/// which allows you to apply it to any `Equatable` key path
///
///    An example of comparing the `keyPath` property in the `.filter(_:)` function:
///
///        let fullLengthArticles = articles.filter(\.category != .fullLength)
///
@inlinable
public func !=<T, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (T) -> Bool {
    { $0[keyPath: lhs] != rhs }
}
