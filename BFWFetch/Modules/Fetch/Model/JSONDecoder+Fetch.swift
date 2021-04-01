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
    
    static var tTimezone: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(tTimezone)
        return decoder
    }
    
    static var timezone: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(timezone)
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
    
    static func tTimezone(_ decoder: Decoder) throws -> Date {
        let dateString = try decoder.singleValueContainer().decode(String.self)
        guard let date = DateFormatter.tTimezone.date(from: dateString)
        else {
            print("\(#function) couldn't decode date string \(dateString)")
            throw Error.dateFormat
        }
        return date
    }
    
    static func timezone(_ decoder: Decoder) throws -> Date {
        let dateString = try decoder.singleValueContainer().decode(String.self)
        guard let date = DateFormatter.timezone.date(from: dateString)
        else {
            print("\(#function) couldn't decode date string \(dateString)")
            throw Error.dateFormat
        }
        return date
    }
    
}
