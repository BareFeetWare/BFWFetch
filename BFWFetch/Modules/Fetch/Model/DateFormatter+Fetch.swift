//
//  DateFormatter+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 19/1/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

public extension DateFormatter {
    
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    /// Format like: 2021-03-13 03:03:37.123+00:00
    static let fractionTimezone = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SZZZ")
    static let sqlDateTime = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
    static let sqlDate = DateFormatter(dateFormat: "yyyy-MM-dd")
    /// Format like: 2021-03-13T03:03:37.123+0000
    static let tFractionTimezone = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SZ")
    /// Format like: 2021-03-13 03:03:37+00:00
    static let timezone = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ssZZZ")
    
}
