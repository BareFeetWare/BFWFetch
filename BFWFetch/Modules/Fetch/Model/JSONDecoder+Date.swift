//
//  JSONDecoder+Date.swift
//
//  Created by Tom Brodhurst-Hill on 8/12/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    
    convenience init(dateDecodingStrategy: DateDecodingStrategy) {
        self.init()
        self.dateDecodingStrategy = dateDecodingStrategy
    }
    
    convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    convenience init(dateFormatters: [DateFormatter]) {
        self.init()
        self.dateDecodingStrategy = .formatted(dateFormatters)
    }
    
}

extension JSONDecoder.DateDecodingStrategy {
    
    enum Error: Swift.Error {
        case dateFormat
    }
    
    static func formatted(_ formatters: [DateFormatter]) -> Self {
        custom(decoderToDateFunction(dateFormatters: formatters))
    }
    
    private static func decoderToDateFunction(dateFormatters: [DateFormatter]) -> (Decoder) throws -> Date {
        { decoder in
            let dateString = try decoder.singleValueContainer().decode(String.self)
            guard let date = (
                dateFormatters
                    .map { $0.date(from: dateString) }
                    .compactMap { $0 }
                    .first
                // TODO: Optimize chain above.
            )
            else {
                debugPrint("\(#function) couldn't decode date string \(dateString)")
                throw Error.dateFormat
            }
            return date
        }
    }
    
}
