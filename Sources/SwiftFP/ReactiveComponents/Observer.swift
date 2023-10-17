//
//  Observer.swift
//  
//
//  Created by Илья Шаповалов on 17.10.2023.
//

import Foundation

public final class Observer<Element> {
    @usableFromInline
    let _on: (Element) -> Void
    
    public init(_ on: @escaping (Element) -> Void) {
        self._on = on
        print(#function)
    }
    
    deinit {
        print(#function)
    }
    
    @inlinable
    func on(_ event: Element) {
        _on(event)
    }
}
