//
//  Zipper.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 21.09.2024.
//

import Foundation

public struct Zipper<Element> {
    public private(set) var previous: [Element]
    public private(set) var current: Element
    public private(set) var next: [Element]
}
