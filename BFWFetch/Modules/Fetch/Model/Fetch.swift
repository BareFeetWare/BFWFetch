//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

// TODO: Remove Fetch:

public enum Fetch {}

// MARK: - Token

public extension Fetch {
    
    private static let tokenKey = "token"
    
    static var token: String? = UserDefaults.standard.string(
        forKey: tokenKey
    ) {
        didSet {
            UserDefaults.standard.setValue(token, forKey: tokenKey)
        }
    }
    
}
