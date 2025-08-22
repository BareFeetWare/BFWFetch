//
//  URL+QueryItem.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 21/8/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Foundation

public extension URL {
    
    func queryItemValue(name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == name })?
            .value
    }
    
}
