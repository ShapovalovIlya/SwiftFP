//
//  Monoid.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 30.11.2024.
//

import Foundation

public protocol Monoid {
    static var empty: Self { get }
    func append(_ other: Self) -> Self
}
