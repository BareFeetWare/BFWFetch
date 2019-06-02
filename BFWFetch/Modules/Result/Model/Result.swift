//
//  Result.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

// TODO: Migrate to use Swift 5's Result.

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public extension Result where Value: Equatable {
    
    static func == (lhs: Result<Value>, rhs: Result<Value>) -> Bool {
        switch (lhs, rhs) {
        case (let .success(left), let .success(right)):
            return left == right
        case (let .failure(leftError), let .failure(rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        default:
            return false
        }
    }
    
}
