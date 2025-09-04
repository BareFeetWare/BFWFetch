//
//  Array+IfLet.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 4/9/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Foundation

public extension Array {
    
    func appendingIf(
        _ condition: Bool,
        elements: () -> [Element]
    ) -> [Element] {
        condition ? self + elements() : self
    }
    
    func appendingIfLet<T>(
        _ optional: T?,
        transform: (T) -> Element
    ) -> [Element] {
        guard let value = optional else { return self }
        return self + [transform(value)]
    }
    
    func appendingIfLet<T>(
        _ optional: T?,
        transform: (T) -> [Element]
    ) -> [Element] {
        guard let value = optional else { return self }
        return self + transform(value)
    }
    
    func appendingIfLet<T, U>(
        _ first: T?,
        _ second: U?,
        transform: (T, U) -> Element
    ) -> [Element] {
        guard let f = first, let s = second else { return self }
        return self + [transform(f, s)]
    }
    
    func appendingIfLet<T, U>(
        _ first: T?,
        _ second: U?,
        transform: (T, U) -> [Element]
    ) -> [Element] {
        guard let f = first, let s = second else { return self }
        return self + transform(f, s)
    }
    
}
