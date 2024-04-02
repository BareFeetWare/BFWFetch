//
//  Bundle+Resource.swift
//
//  Created by Tom Brodhurst-Hill on 2/11/2023.
//

import Foundation

public extension Bundle {
    
    enum Error: LocalizedError {
        case resource
        
        public var errorDescription: String? {
            switch self {
            case .resource: "Missing resource"
            }
        }
    }
    
    func contents(resource: String, arguments: CVarArg...) throws -> String {
        guard let queryURL = url(forResource: resource, withExtension: nil)
        else { throw Self.Error.resource }
        do {
            let format = try String(contentsOf: queryURL)
            return String(format: format, arguments)
        } catch {
            throw error
        }
    }
    
}
