//
//  ReaderTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 22.11.2024.
//

import Foundation
import Testing
@testable import SwiftFP

extension Int {
    var isEven: Bool { self % 2 == 0 }
}

struct ReaderTests {
    static let arguments = [1,2,3,4,5]
    typealias Sut = Reader<Int, String>
    let sut = Sut(\.description)
    
    @Test(arguments: arguments)
    func apply(_ value: Int) async throws {
        #expect(sut.apply(value) == value.description)
    }
    
    @Test(arguments: arguments)
    func joined(_ value: Int) async throws {
        let sut = Reader.pure(Sut.pure(value.description)).joined()
        
        #expect(sut.apply(value) == value.description)
    }
    
    @Test func pure() async throws {
        let sut = Sut.pure("baz")
        
        #expect(sut.apply(1) == "baz")
    }
    
    @Test func map() async throws {
        let sut = sut.map(\.count)
        
        #expect(sut(1) == 1)
        #expect(sut(10) == 2)
        #expect(sut(100) == 3)
    }
    
    @Test func flatMap() async throws {
        let sut = sut.flatMap { description in
            Sut {
                description
                    .appending(" is even: ")
                    .appending($0.isEven.description)
            }
        }
        
        #expect(sut(1) == "1 is even: false")
        #expect(sut(2) == "2 is even: true")
    }
    
    @Test func zip() async throws {
        let first = Sut(\.description)
        let second = Reader<Int, Bool>(\.isEven)
        
        let sut = first.zip(second)
        
        #expect(sut(1) == ("1", false))
        #expect(sut(2) == ("2", true))
    }
    
    @Test func zipInto() async throws {
        struct Model: Equatable {
            let description: String
            let isEven: Bool
            
            @Sendable init(description: String, isEven: Bool) {
                self.description = description
                self.isEven = isEven
            }
        }
        
        let first = Sut(\.description)
        let second = Reader<Int, Bool>(\.isEven)
        let sut = first.zip(second, into: Model.init)
        
        let oddModel = sut(1)
        #expect(oddModel.description == "1")
        #expect(oddModel.isEven == false)
        
        let eventModel = sut(2)
        #expect(eventModel.description == "2")
        #expect(eventModel.isEven)
    }
    
    @Test func tryMapValue() async throws {
        @Sendable func addOne(_ int: Int) throws -> Int { int + 1 }
        let sut = Reader<Int, Int>(\.self).tryMap(addOne)
        
        try #expect(sut.apply(1).get() == 2)
    }
    
    @Test func tryMapError() async throws {
        @Sendable func addOne(_ int: Int) throws -> Int {
            throw NSError(domain: "Test", code: 1)
        }
        let sut = Reader<Int, Int>(\.self).tryMap(addOne)
        
        #expect(throws: NSError.self, performing: sut.apply(1).get)
    }
    
    @Test func pullback() async throws {
        @Sendable func doubleToInt(_ double: Double) -> Int { Int(double) }
        
        let sut = Sut(\.description).pullback(doubleToInt)
        
        #expect(sut(2.0) == "2")
    }
    
    @Test func carry() async throws {
        let addOne = Reader<Int, Int> { $0 + 1 }
        let describe = Sut(\.description)
        let checkEmpty = Reader<String, Bool>(\.isEmpty)
        
        let three = addOne.curry(addOne)
                    
        #expect(three(1) == 3)
        
        let described = three.curry(describe)
        
        #expect(described(1) == "3")
        
        let isEmpty = described.curry(checkEmpty)
        
        #expect(isEmpty(1) == false)
    }
    
    @Test func addOther() async throws {
        let addOne = Reader<Int, Int> { $0 + 1 }
        
        let addTwo = addOne + addOne
        
        #expect(addTwo(1) == 3)
    }
    
    @Test func zipPackOfReaders() async throws {
        let sut = Reader.zip(
            Reader<Int, String>(\.description),
            Reader<Int, Bool>(\.isEven),
            Reader<Int, UInt>(UInt.init(bitPattern:))
        )
        
        #expect(sut.apply(42) == ("42", true, 42))
    }
}
