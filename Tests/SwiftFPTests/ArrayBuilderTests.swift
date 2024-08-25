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

    //MARK: - Array
    @Test
    func createArrayFromElements() async throws {
        let sut = Array {
            1
            2
            3
        }
        
        #expect(sut == [1,2,3])
    }
    
    @Test(arguments: [true, false])
    func createArrayWithIfBranch(condition: Bool) async throws {
        let sut = Array {
            1
            if condition {
                2
            }
        }
        
        let exp = condition ? [1,2] : [1]
        #expect(sut == exp)
    }

    @Test(arguments: [true, false])
    func createArrayWithIfElseBranch(condition: Bool) async throws {
        let sut = Array {
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
    func createArrayWithSwitch(condition: Bool) async throws {
        let sut = Array {
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
    func createArrayWithArray() async throws {
        let sut = Array {
            1
            [2]
        }
        
        #expect(sut == [1,2])
    }
    
    @Test
    func createArrayWithVoidExpression() async throws {
        let sut = try Array {
            1
            try #require(true)
        }
        
        #expect(sut == [1])
    }
    
    //MARK: - Dictionary
    @Test
    func createDictWithPairs() async throws {
        let sut = Dictionary {
            ("baz", 1)
        }
        
        #expect(sut == ["baz": 1])
    }
}
