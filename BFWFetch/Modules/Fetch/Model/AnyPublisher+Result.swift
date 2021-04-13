//
//  AnyPublisher+Result.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 13/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

public extension AnyPublisher {
    
    /// Map into a result publisher, which never fails. The Failure moves into the result.
    func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        self
            .map { Result.success($0) }
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }

}
