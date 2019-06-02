//
//  Root.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import BFWFetch

final class Root: Observable {
    
    /// Root instance for all model objects.
    static let shared = Root()
    
    var sites: [Site]? { didSet { post(keyPath: \.sites) }}
    
}
