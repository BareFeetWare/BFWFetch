//
//  DateFormatter+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 19/1/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

public extension DateFormatter {
    
    static let sqlDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let sqlDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// Format like: 2021-03-13T03:03:37.123+0000
    static let tTimezone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    /// Format like: 2021-03-13 03:03:37+00:00
    static let timezone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
        return formatter
    }()
    
}
