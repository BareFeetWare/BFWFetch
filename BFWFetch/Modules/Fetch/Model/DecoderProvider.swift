//
//  DecoderProvider.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 22/5/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation

/// A convenience to provide the decoder and mappedError in the Decodable type.
public protocol DecoderProvider: Decodable {
    
    static var decoder: JSONDecoder { get }
    static func mappedError(_ error: Error) -> Error
    
}

public extension DecoderProvider {
    
    static func mappedError(_ error: Error) -> Error {
        error
    }
    
}
