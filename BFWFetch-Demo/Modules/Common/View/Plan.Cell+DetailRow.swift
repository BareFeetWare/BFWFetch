//
//  Plan.Cell+DetailRow.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 25/3/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

extension Plan.Cell {
    static func detail(title: String, trailing: String?) -> Self {
        .init {
            DetailRow(title: title, trailing: trailing)
        }
    }
}
