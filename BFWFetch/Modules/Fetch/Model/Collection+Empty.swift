//
//  Collection+Empty.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 5/9/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

public extension Collection {
    var nilIfEmpty: Self? { isEmpty ? nil : self }
}
