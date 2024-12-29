//
//  ReaderTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 22.11.2024.
//

import Foundation
import Testing
import SwiftFP

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
    
    @Test func readerSubscript() async throws {
        let sut = Reader<URL, URLRequest>
            .init { URLRequest(url: $0) }
            .httpMethod("GET")
        
        #expect(sut.apply(URL(string: "MyURL")!).httpMethod == "GET")
    }
    
    @Test func tryMapValue() async throws {
        func addOne(_ int: Int) throws -> Int { int + 1 }
        let sut = Reader<Int, Int>(\.self).tryMap(addOne)
        
        try #expect(sut.apply(1).get() == 2)
    }
    
    @Test func tryMapError() async throws {
        func addOne(_ int: Int) throws -> Int {
            throw NSError(domain: "Test", code: 1)
        }
        let sut = Reader<Int, Int>(\.self).tryMap(addOne)
        
        #expect(throws: NSError.self, performing: sut.apply(1).get)
    }
}
