//
//  EffectTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 30.11.2024.
//

import Testing
import SwiftFP

struct EffectTest {
    static let arguments = [1,2,3,4,5]
    
    @Test(arguments: arguments)
    func pure(_ value: Int) {
        let sut = Effect.pure(value)
        
        #expect(sut.run() == value)
    }
    
    @Test(arguments: arguments)
    func run(_ value: Int) async throws {
        let sut = Effect.pure(value)
        
        #expect(sut.run() == value)
    }
    
    @Test(arguments: arguments)
    func joined(_ value: Int) async throws {
        let sut = Effect.pure(Effect { value }).joined()
        
        #expect(sut.run() == value)
    }

    @Test(arguments: arguments)
    func map(_ value: Int) async throws {
        let sut = Effect.pure(value).map(\.description)
        
        #expect(sut.run() == value.description)
    }
    
    @Test(arguments: arguments)
    func flatMap(_ value: Int) async throws {
        func descriptionEffect(_ val: Int) -> Effect<String> { Effect { val.description } }
        let sut = Effect.pure(value).flatMap(descriptionEffect)
        
        #expect(sut.run() == value.description)
    }
    
    @Test func zip() async throws {
        let other = Effect.pure("baz")
        let sut = Effect.pure(1).zip(other)
        
        #expect(sut.run() == (1, "baz"))
    }
    
    @Test func zipInto() async throws {
        let lhs = Effect.pure(1)
        let rhs = Effect.pure(2)
        let sut = lhs.zip(rhs, into: +)
        
        #expect(sut.run() == 3)
    }
}
