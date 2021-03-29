//
//  DateFormatter+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 19/1/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension DateFormatter {
    
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

    static let tSeparator: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

}
