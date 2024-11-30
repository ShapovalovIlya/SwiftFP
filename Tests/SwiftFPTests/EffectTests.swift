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
    func run(_ value: Int) async throws {
        let sut = Effect { value }
        
        #expect(sut.run() == value)
    }

    @Test(arguments: arguments)
    func map(_ value: Int) async throws {
        
    }
}
