//
//  String+SnakeCase.swift
//
//  Created by Tom Brodhurst-Hill on 1/3/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

// Adapted from: https://gist.github.com/dmsl1805/ad9a14b127d0409cf9621dc13d237457

import Foundation

public extension String {
    
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.replacedRegex(pattern: acronymPattern)?
            .replacedRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
    }
    
    func camelCaseToWords() -> String {
        replacingOccurrences(
            of: "([a-z])([A-Z])",
            with: "$1 $2",
            options: .regularExpression
        )
    }
    
}

fileprivate extension String {
    
    // TODO: Perhaps update to not use NSRegularExpression.
    
    func replacedRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
    
}
