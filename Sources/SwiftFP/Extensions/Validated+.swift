//
//  Validated+.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 19.03.2025.
//

import Foundation
import Readers
import Validated

public extension Validated {
    typealias Parser = Reader<Success, Result<Success, Failure>>
    
    @inlinable
    init(_ state: Success, parsers: [Parser]) {
        self.init(
            reduce: state,
            validators: parsers.map { $0.apply(_:) }
        )
    }
}
