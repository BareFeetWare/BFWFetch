//
//  Codable​+​User​Defaults​.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 22/2/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

public extension Decodable where Self: Encodable {
    
    static func userDefault(
        forKey key: String = #function
    ) -> Self? {
        UserDefaults.standard.data(forKey: key)
            .flatMap { try? JSONDecoder().decode(Self.self, from: $0) }
    }
    
    static func userDefault(
        forKey key: String = #function,
        default defaultValue: Self
    ) -> Self {
        userDefault(forKey: key) ?? defaultValue
    }
}

public extension Encodable {
    
    func setUserDefault(
        forKey key: String = #function
    ) {
        UserDefaults.standard.set(
            try? JSONEncoder().encode(self),
            forKey: key
        )
    }
}

public extension Optional where Wrapped: Encodable {
    
    func setUserDefault(
        forKey key: String = #function
    ) {
        if let self {
            self.setUserDefault(forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
