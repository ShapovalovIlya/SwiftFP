//
//  Compose.swift
//
//
//  Created by Илья Шаповалов on 16.08.2023.
//

public typealias TransformValue<T> = (T) -> (T)

public func compose<T>(
    _ a: @escaping TransformValue<T>,
    _ b: @escaping TransformValue<T>,
    _ c: @escaping TransformValue<T>
) -> TransformValue<T> {
    { a(b(c($0))) }
}

public func pipe<T>(
    _ a: @escaping TransformValue<T>,
    _ b: @escaping TransformValue<T>,
    _ c: @escaping TransformValue<T>
) -> TransformValue<T> {
    { c(b(a($0))) }
}
