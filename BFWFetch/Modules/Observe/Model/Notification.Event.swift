//
//  Notification.Event.swift
//
//  Created by Tom Brodhurst-Hill on 16/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public extension Notification {
    
    fileprivate enum Key: String {
        case event
    }
    
    enum Event: Equatable {
        case inProgress
        case failure(error: Error)
        case success
        case changed
        // If adding a case, be sure to add to the func == below:
        
        public static func == (lhs: Notification.Event, rhs: Notification.Event) -> Bool {
            switch (lhs, rhs) {
            case (.inProgress, .inProgress),
                 (.failure(_), .failure(_)),
                 (.success, .success),
                 (.changed, .changed):
                return true
            default:
                return false
            }
        }

    }
    
    var event: Event? {
        get {
            return userInfo?[Key.event.rawValue] as? Event
        }
        set {
            userInfo?[Key.event.rawValue] = newValue
        }
    }
    
    init(name: Notification.Name, object: Any?, event: Event = .changed) {
        self.init(name: name, object: object, userInfo: [Key.event.rawValue : event])
    }
    
    init<Root, Value>(keyPath: KeyPath<Root, Value>, object: Any?, event: Event = .changed) {
        let name = Notification.Name(keyPath: keyPath)
        self.init(name: name, object: object, event: event)
    }
    
}

public extension Notification.Name {
    
    init<Root, Value>(keyPath: KeyPath<Root, Value>) {
        self.init(String(describing: keyPath))
    }
    
}
