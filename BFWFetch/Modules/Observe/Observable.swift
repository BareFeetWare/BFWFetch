//
//  Observable.swift
//
//  Created by Tom Brodhurst-Hill on 12/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public protocol Observable {}

public extension Observable {
    
    public func post(_ notification: Notification) {
        NotificationCenter.default.post(notification)
    }
    
    public func post(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        let notification = Notification(name: name, object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: - KeyPath and Event:
    
    public func post<Value>(keyPath: KeyPath<Self, Value>, event: Notification.Event = .changed) {
        let notification = Notification(keyPath: keyPath, object: self, event: event)
        NotificationCenter.default.post(notification)
    }
    
    public func addObserver<Value>(
        of keyPath: KeyPath<Self, Value>,
        events: [Notification.Event] = [],
        queue: OperationQueue = OperationQueue.current!,
        using block: @escaping (Notification) -> Void)
    {
        NotificationCenter.default.addObserver(
            forName: Notification.Name(keyPath: keyPath),
            object: self,
            queue: queue)
        { notification in
            guard events == [] || notification.event != nil && events.contains(notification.event!)
                else { return }
            block(notification)
        }
    }

}
