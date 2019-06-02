//
//  Sites+Decodable.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

extension Array where Element == Site {
    
    init(from decoder: Decoder) throws {
        let json = try JSON(from: decoder)
        self = json.list
    }
    
    private struct JSON: Decodable {
        let list: [Site]
    }
    
}
