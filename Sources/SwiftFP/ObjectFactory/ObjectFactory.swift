//
//  ObjectFactory.swift
//  Messanger
//
//  Created by Шаповалов Илья on 22.07.2024.
//  Copyright © 2024 insystem. All rights reserved.
//

import Foundation

//MARK: - ObjectFactory
@dynamicMemberLookup
public struct ObjectFactory<T> {
    public let obj: T
    
    @inlinable
    public init(_ obj: T) { self.obj = obj }
    
    @inlinable
    public subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<T, Value>
    ) -> (Value) -> T {
        { [obj] value in
            var obj = obj
            obj[keyPath: keyPath] = value
            return obj
        }
    }
    
    @inlinable
    public subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<T, Value>
    ) -> (Value) -> ObjectFactory<T> {
        { [obj] value in
            var obj = obj
            obj[keyPath: keyPath] = value
            return ObjectFactory(obj)
        }
    }
}

//MARK: - FactoryCompatibleObject
public protocol FactoryCompatible {
    associatedtype ObjectType
    var factory: ObjectFactory<ObjectType> { get }
}

public extension FactoryCompatible {
    var factory: ObjectFactory<Self> { ObjectFactory(self) }
}
