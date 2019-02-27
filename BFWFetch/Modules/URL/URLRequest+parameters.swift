//
//  URLRequest+parameters.swift
//
//  Created by Tom Brodhurst-Hill on 8/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    var parameters: [String : String]? {
        get {
            guard let data = httpBody,
                let string = String(data: data, encoding: .utf8)
                else { return nil }
            return string.components(separatedBy: "&").reduce([String : String]()) { (dictionary, substring) in
                var newDictionary = dictionary
                let components = substring.components(separatedBy: "=")
                if components.count == 2 {
                    let key = components[0]
                    let value = components[1]
                    newDictionary[key] = value
                }
                return newDictionary
            }
        }
        set {
            let parametersString = newValue?.map { (key: String, value: String) in
                "\(key)=\(value)"
                }
                .joined(separator: "&")
            httpBody = parametersString?.data(using: .utf8)
        }
    }
    
    mutating func appendHeaderFields(_ headerFields: [String : String]) {
        headerFields.forEach { element in
            setValue(element.value, forHTTPHeaderField: element.key)
        }
    }
    
}
