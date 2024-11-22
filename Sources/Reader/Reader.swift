//
//  Reader.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 20.11.2024.
//

import Foundation

public struct Reader<Environment, Result> {
    public let run: (Environment) -> Result
    
    @inlinable
    init(_ run: @escaping (Environment) -> Result) { self.run = run }
    
    @inlinable
    public func map<U>(_ transform: @escaping (Result) -> U) -> Reader<Environment, U> {
        Reader<Environment, U> { transform(run($0)) }
    }
}
