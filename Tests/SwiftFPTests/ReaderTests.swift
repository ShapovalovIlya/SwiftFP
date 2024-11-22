//
//  ReaderTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 22.11.2024.
//

import Foundation
import Testing
import SwiftFP
import Reader

extension Int {
    var isEven: Bool { self % 2 == 0 }
}

struct ReaderTests {
    let sut = Reader<Int, String>(\.description)
    
    @Test func map() async throws {
        let sut = sut.map(\.count)
        
        #expect(sut.run(1) == 1)
        #expect(sut.run(10) == 2)
        #expect(sut.run(100) == 3)
    }
    
    @Test func flatMap() async throws {
        let sut = sut.flatMap { description in
            Reader<Int, String> {
                description
                    .appending(" is even: ")
                    .appending($0.isEven.description)
            }
        }
        
        #expect(sut.run(1) == "1 is even: false")
        #expect(sut.run(2) == "2 is even: true")
    }
    
    @Test func zip() async throws {
        let first = Reader<Int, String>(\.description)
        let second = Reader<Int, Bool>(\.isEven)
        
        let sut = first.zip(second)
        
        #expect(sut.run(1) == ("1", false))
        #expect(sut.run(2) == ("2", true))
    }
    
    @Test func zipInto() async throws {
        struct Model: Equatable {
            let description: String
            let isEven: Bool
        }
        
        let first = Reader<Int, String>(\.description)
        let second = Reader<Int, Bool>(\.isEven)
        let sut = first.zip(second, into: Model.init)
        
        let oddModel = sut.run(1)
        #expect(oddModel.description == "1")
        #expect(oddModel.isEven == false)
        
        let eventModel = sut.run(2)
        #expect(eventModel.description == "2")
        #expect(eventModel.isEven)
    }
}
