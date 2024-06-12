//
//  DateFormatter+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 19/1/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

public extension DateFormatter {
    
    static var dateTimeISO8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = .init(identifier: .iso8601)
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }
    
    static let dayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let hour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let long: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let timeMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
    
    // MARK: - Using dateFormat: String
    
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    static let api = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
    
    static let day = DateFormatter(dateFormat: "EEEE")
    
    static let dayN = DateFormatter(dateFormat: "d")
    
    /// Format like: 2021-03-13 03:03:37.123+00:00
    static let fractionTimezone = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SZZZ")
    
    static let longMonthYear = DateFormatter(dateFormat: "d MMMM yyyy")
    
    static let monthDay = DateFormatter(dateFormat: "MMMM d")
    
    static let monthYear = DateFormatter(dateFormat: "MMMM yyyy")
    
    static let shortMonth = DateFormatter(dateFormat: "MMM")
    
    static let shortMonthYear = DateFormatter(dateFormat: "MMM yyyy")
    
    static let sqlDateTime = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
    
    static let sqlDate = DateFormatter(dateFormat: "yyyy-MM-dd")
    
    /// Format like: 2021-03-13T03:03:37.123+0000
    static let tFractionTimezone = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SZ")
    
    /// Format like: 2021-03-13 03:03:37+00:00
    static let timezone = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ssZZZ")
    
    /// Format like: 2021-03-13T03:03:37Z
    static let tTimezone = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
    
    static let weekdayInitial = DateFormatter(dateFormat: "EEEEE")
    
    static let weekdayMonthYear = DateFormatter(dateFormat: "EEE, d MMM yyyy")
    
    static let year = DateFormatter(dateFormat: "yyyy")
    
}
