//
//  JSONDecoder+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 8/12/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    
    static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    static var sqlDate: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(sqlDate)
        return decoder
    }
    
    static var tSeparator: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(tSeparator)
        return decoder
    }
    
    enum Error: Swift.Error {
        case dateFormat
    }
    
    static func sqlDate(_ decoder: Decoder) throws -> Date {
        let dateString = try decoder.singleValueContainer().decode(String.self)
        guard let date = DateFormatter.sqlDateTime.date(from: dateString)
                ?? DateFormatter.sqlDate.date(from: dateString)
        else {
            print("\(#function) couldn't decode date string \(dateString)")
            throw Error.dateFormat
        }
        return date
    }
    
    static func tSeparator(_ decoder: Decoder) throws -> Date {
        let dateString = try decoder.singleValueContainer().decode(String.self)
        guard let date = DateFormatter.tSeparator.date(from: dateString)
        else {
            print("\(#function) couldn't decode date string \(dateString)")
            throw Error.dateFormat
        }
        return date
    }
    
}
