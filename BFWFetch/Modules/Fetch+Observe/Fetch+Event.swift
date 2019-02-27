//
//  Fetch+Event.swift
//
//  Created by Tom Brodhurst-Hill on 26/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetch.Result {
    
    var event: Notification.Event {
        switch self {
        case .success(_): return .success
        case .failure(let error): return .failure(error: error)
        }
    }
    
}
