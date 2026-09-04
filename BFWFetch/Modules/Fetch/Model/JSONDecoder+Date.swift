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
    
    convenience init(dateFormatters: [DateFormatting]) {
        self.init()
        self.dateDecodingStrategy = .formatted(dateFormatters)
    }
    
}

extension JSONDecoder.DateDecodingStrategy {
    
    static func formatted(_ formatters: [DateFormatting]) -> Self {
        custom(decoderToDateFunction(dateFormatters: formatters))
    }
    
    /// Reads the date with the first formatter that recognises it, and throws a `DecodingError` naming the value and where it sat when none does — so a caller catching it learns which string could not be read and not only that one could not.
    private static func decoderToDateFunction(dateFormatters: [DateFormatting]) -> (Decoder) throws -> Date {
        { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = dateFormatters
                .lazy
                .compactMap({ $0.date(from: dateString) })
                .first
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Date not in any of the \(dateFormatters.count) expected formats: \(dateString)"
                )
            }
            return date
        }
    }
    
}
