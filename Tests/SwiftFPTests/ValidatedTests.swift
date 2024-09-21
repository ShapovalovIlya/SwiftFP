//
//  ValidatedTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Testing
import Validated
import Foundation

struct ValidatedTests {
    typealias Sut = Validated<Int, StubError>
    typealias ValidationResult = Result<Int, StubError>
    
    private static let arguments = [
        Sut(1),
        Sut.failed(.one)
    ]
    
    enum StubError: Error, Equatable {
        case one
        case two
    }
    
    enum MappedError: Error, Equatable {
        case one
        case two
        
        init(stub: StubError) {
            switch stub {
            case .one:
                self = .one
                
            case .two:
                self = .two
            }
        }
    }
    
    //MARK: - init
    @Test
    func initialState() async throws {
        let sut = Sut(1)
        
        #expect(sut == .valid(1))
    }
    
    @Test
    func initialFailed() async throws {
        let sut = Sut.failed(.one)
        
        let expected = try #require(NotEmptyArray<StubError>([.one]))
        #expect(sut == .invalid(expected))
    }
    
    @Test
    func catchInit() async throws {
        let sut = Validated(catch: { 1 })
        
        switch sut {
        case .valid(let value): #expect(value == 1)
        case .invalid: throw NSError()
        }
    }
    
    @Test
    func catchErrorInit() async throws {
        let sut = Validated { throw StubError.one }
        
        switch sut {
        case .valid: throw NSError()
        case .invalid(let errors): #expect(errors.head is StubError)
        }
    }
    
    @Test(arguments: [
        Result<Int, StubError>.success(1),
        .failure(.one)
    ])
    func initWithResult(_ result: Result<Int, StubError>) async throws {
        let sut = Validated(result: result)
        
        switch (result, sut) {
        case let (.success(lhs) ,.valid(rhs)):
            #expect(lhs == rhs)
            
        case let (.failure(lhs), .invalid(rhs)):
            #expect(rhs.contains(lhs))
            
        default: throw NSError()
        }
    }
    
    //MARK: - map
    @Test(arguments: arguments)
    func map(_ state: Sut) async throws {
        let sut = state.map(\.description)
        
        switch state {
        case .valid(let wrapped):
            #expect(sut == Validated<String, StubError>(wrapped.description))
            
        case .invalid(let errors):
            #expect(sut == Validated<String, StubError>.invalid(errors))
        }
    }
    
    @Test(arguments: arguments)
    func mapErrors(_ state: Sut) async throws {
        let sut = state.mapErrors(MappedError.init)
        
        switch state {
        case .valid(let wrapped):
            #expect(sut == Validated<Int, MappedError>(wrapped))
            
        case .invalid:
            #expect(sut == Validated<Int, MappedError>.failed(.one))
        }
    }
    
    @Test
    func tryMap() async throws {
        let sut = Sut(1).tryMap { _ in throw StubError.one }
        
        switch sut {
        case .valid: throw NSError()
        case .invalid(let errors): #expect(errors.head is StubError)
        }
    }
    
    //MARK: - flatMap
    @Test(arguments: arguments)
    func flatMap(_ state: Sut) async throws {
        let sut = state.flatMap {
            Validated<String, StubError>($0.description)
        }
        
        switch state {
        case .valid(let wrapped):
            #expect(sut == Validated<String, StubError>(wrapped.description))
            
        case .invalid(let errors):
            #expect(sut == Validated<String, StubError>.invalid(errors))
        }
    }
    
    @Test(arguments: arguments)
    func flatMapErrors(_ state: Sut) async throws {
        let sut = state.flatMapErrors { error in
            let transformed = error.mapNotEmpty(MappedError.init)
            return Validated<Int, MappedError>.invalid(transformed)
        }
        
        switch state {
        case .valid(let wrapped):
            #expect(sut == Validated<Int, MappedError>(wrapped))
            
        case .invalid:
            #expect(sut == Validated<Int, MappedError>.failed(.one))
        }
    }
    
    //MARK: - zip
    @Test(arguments: arguments)
    func zipValid(_ other: Sut) async throws {
        let sut = Sut(1).zip(other)
        
        switch (other, sut) {
        case let (.valid, .valid(pair)):
            #expect(pair == (1,1))
            
        case let (.invalid(lhs), .invalid(rhs)):
            #expect(lhs == rhs)
        
        default: throw NSError()
        }
    }
    
    @Test(arguments: arguments)
    func zipInvalid(_ other: Sut) async throws {
        let sut = Sut.failed(.one).zip(other)
        
        switch (other, sut) {
        case let (.valid, .invalid(errors)):
            #expect(errors.array == [.one])
            
        case let (.invalid, .invalid(errors)):
            #expect(errors.array == [.one, .one])
            
        default: throw NSError()
        }
    }
    
    @Test(arguments: arguments)
    func zipValidUsingTransform(_ other: Sut) async throws {
        let sut = Sut(1).zip(other) { $0 + $1 }
        
        switch (other, sut) {
        case let (.valid, .valid(accumulated)):
            #expect(accumulated == 2)
            
        case let (.invalid(lhs), .invalid(rhs)):
            #expect(lhs == rhs)
        
        default: throw NSError()
        }
    }
    
    @Test(arguments: arguments)
    func zipGlobal(_ state: Sut) async throws {
        let sut = zip(
            Validated<String, StubError>("1"),
            state
        )
        
        switch (state, sut) {
        case let (.valid, .valid(pair)):
            #expect(pair == ("1", 1))
            
        case let (.invalid(lhs), .invalid(rhs)):
            #expect(lhs == rhs)
            
        default: throw NSError()
        }
    }
    
//    @Test(arguments: [
//        (Sut(1), Sut(1)),
//        (Sut(1), Sut.failed(.one)),
//        (Sut.failed(.one), Sut.failed(.one))
//    ])
//    func zipGlobalWithClosure(_ pair: (lhs: Sut, rhs: Sut)) async throws {
//        let sut = zip(pair.lhs, pair.rhs, using: +)
//        
//        switch (pair) {
//        case let (.valid(lhs), .valid(rhs)):
//            
//        }
//    }
    
    @Test
    func accumulateErrors() async throws {
        let sut = Sut(1).validate { wrapped in
            Sut(wrapped)
            Sut.failed(.one)
            Sut.failed(.two)
            ValidationResult.success(2)
            NotEmptyArray(head: Sut(1), tail: [])
        }
        
        switch sut {
        case .invalid(let errors):
            #expect(errors.array == [.one, .two])
            
        case .valid:
            throw NSError()
        }
    }
    
    @Test
    func accumulateValidations() async throws {
        let sut = Sut(1).validate { wrapped in
            Sut(4)
            ValidationResult.success(2)
            NotEmptyArray(head: Sut(3), tail: [])
        }
        
        switch sut {
        case .valid(let wrapped):
            #expect(wrapped == 1)
            
        case .invalid: throw NSError()
        }
    }
}
