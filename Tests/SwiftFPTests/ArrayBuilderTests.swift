//
//  ArrayBuilderTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.08.2024.
//

import Testing
import SwiftFP

@Suite("Tests for array builder")
struct ArrayBuilderTests {

    @Test
    func createFromElements() async throws {
        let sut = Array<Int> {
            1
            2
            3
        }
        
        #expect(sut == [1,2,3])
    }
    
    @Test(arguments: [true, false])
    func createWithIfBranch(condition: Bool) async throws {
        let sut = Array<Int> {
            1
            if condition {
                2
            }
        }
        
        let exp = condition ? [1,2] : [1]
        #expect(sut == exp)
    }

    @Test(arguments: [true, false])
    func createWithIfElseBranch(condition: Bool) async throws {
        let sut = Array<Int> {
            1
            if condition {
                2
            } else {
                3
            }
        }
        
        let exp = condition ? [1,2] : [1,3]
        #expect(sut == exp)
    }
    
    
    @Test(arguments: [true, false])
    func createWithSwitch(condition: Bool) async throws {
        let sut = Array<Int> {
            1
            switch condition {
            case true: 2
            case false: 3
            }
        }
        
        let exp = condition ? [1,2] : [1,3]
        #expect(sut == exp)
    }
    
    @Test
    func createWithArray() async throws {
        let sut = Array<Int> {
            1
            [2]
        }
        
        #expect(sut == [1,2])
    }
    
    @Test
    func createWithVoidExpression() async throws {
        let sut = try Array<Int> {
            1
            try #require(true)
        }
        
        #expect(sut == [1])
    }
    
}
