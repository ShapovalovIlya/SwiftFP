//
//  Observable.swift
//
//
//  Created by Илья Шаповалов on 17.10.2023.
//

import Foundation
import PropertyWrappers

public struct Observable<Element> {
    @usableFromInline var observers: [WeakObject<Observer<Element>>]
    
    var value: Element {
        didSet {
            observers.forEach { $0.wrappedValue?.on(value) }
        }
    }
    
    public init(value: Element) {
        self.value = value
        self.observers = .init()
    }
    
    @inlinable
    public mutating func subscribe(on observer: Observer<Element>) {
        self.observers.append(.init(observer))
    }
}
