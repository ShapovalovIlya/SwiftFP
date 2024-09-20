//
//  Validated.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation
import NotEmptyArray

public enum Validated<Value, Failure> where Failure: Swift.Error {
    case valid(Value)
    case invalid(NotEmptyArray<Failure>)
    
    init(_ wrapped: Value) {
        self = .valid(wrapped)
    }
    
    static func failed(_ error: Failure) -> Validated {
        .invalid(NotEmptyArray(head: error, tail: []))
    }
}

extension Validated: Equatable where Value: Equatable, Failure: Equatable {}
