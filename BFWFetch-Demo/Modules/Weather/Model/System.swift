//
//  System.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 6/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

/// Measurement system, such as metric, imperial.
enum System: CaseIterable, Identifiable {
    case metric
    case imperial
    
    var id: Self { self }
    
    var title: String {
        String(describing: self).capitalized
    }
}

extension System: FetchValue {}
