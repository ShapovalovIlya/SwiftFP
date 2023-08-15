//
//  Functor.swift
//
//
//  Created by Илья Шаповалов on 16.08.2023.
//

import Foundation

public struct Functor<F1, F2> {
    private let f: (F1) -> F2
    
    public init(_ f: @escaping (F1) -> F2) {
        self.f = f
    }
    
    @discardableResult public func run(_ args: F1) -> F2 {
        f(args)
    }
    
    @discardableResult public func run(_ args: F1, times: Int) -> F2 {
        for _ in 1...times {
            self.run(args)
        }
        return f(args)
    }
    
    @discardableResult public func retry(_ args: F1, maxTries: Int, condition: () -> Bool) -> F2 {
        var tries = 0
        var result: F2?
        
        while !condition() && tries < maxTries {
            result = f(args)
            tries += 1
        }
        
        return result!
    }
}
