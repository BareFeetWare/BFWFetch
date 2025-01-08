//
//  Bundle+Resource.swift
//
//  Created by Tom Brodhurst-Hill on 2/11/2023.
//

import Foundation

public extension Bundle {
    
    enum Error: LocalizedError {
        case missingResource
        
        public var errorDescription: String? {
            switch self {
            case .missingResource: "Missing resource in bundle."
            }
        }
    }
    
    func contents(resource: String, arguments: CVarArg...) throws -> String {
        guard let queryURL = url(forResource: resource, withExtension: nil)
        else {
            throw Self.Error.missingResource
        }
        do {
            let format = try String(contentsOf: queryURL)
            return String(format: format, arguments)
        } catch {
            throw error
        }
    }
    
    func decoded<T: Decodable>(fileName: String, type: T.Type? = nil) async throws -> T {
        guard let url = url(forResource: fileName, withExtension: nil, subdirectory: nil)
        else {
            throw Error.missingResource
        }
        let request = URLRequest(url: url)
        let response: T = try await request.decodedResponse()
        return response
    }
    
    func data(forResource resource: String, withExtension fileExtension: String? = nil) throws -> Data {
        guard let url = url(forResource: resource, withExtension: fileExtension, subdirectory: nil)
        else {
            throw Error.missingResource
        }
        let data = try Data(contentsOf: url)
        return data
    }
    
}
