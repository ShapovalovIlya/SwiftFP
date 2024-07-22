//
//  RefObjectFactory.swift
//  Messanger
//
//  Created by Шаповалов Илья on 22.07.2024.
//  Copyright © 2024 insystem. All rights reserved.
//

import Foundation

//MARK: - RefObjectFactory
@dynamicMemberLookup
public struct RefObjectFactory<T> {
    public let obj: T
    
    @inlinable
    public init(_ obj: T) where T: AnyObject { self.obj = obj }
    
    @inlinable
    public subscript<Value>(
        dynamicMember keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> (Value) -> T where T: AnyObject {
        { value in
            obj[keyPath: keyPath] = value
            return obj
        }
    }
    
    @inlinable
    public subscript<Value>(
        dynamicMember keyPath: ReferenceWritableKeyPath<T, Value>
    ) -> (Value) -> RefObjectFactory<T> where T: AnyObject {
        { value in
            obj[keyPath: keyPath] = value
            return self
        }
    }
}

//MARK: - FactoryCompatibleObject
public protocol FactoryCompatibleObject: AnyObject {
    associatedtype ObjectType
    var factory: RefObjectFactory<ObjectType> { get }
}

public extension FactoryCompatibleObject {
    var factory: RefObjectFactory<Self> { RefObjectFactory(self) }
}
