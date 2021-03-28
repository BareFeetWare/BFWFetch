//
//  Observable.swift
//
//  Created by Tom Brodhurst-Hill on 12/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public protocol Observable {}

public extension Observable {
    
    func post(_ notification: Notification) {
        NotificationCenter.default.post(notification)
    }
    
    func post(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        let notification = Notification(name: name, object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: - Event
    
    func post(name: Notification.Name, event: Notification.Event = .changed) {
        let notification = Notification(name: name, object: self, event: event)
        NotificationCenter.default.post(notification)
    }

    func addObserver(
        ofName name: Notification.Name,
        events: [Notification.Event] = [],
        queue: OperationQueue = OperationQueue.current!,
        using block: @escaping (Notification) -> Void)
    {
        NotificationCenter.default.addObserver(
            forName: name,
            object: self,
            queue: queue
        ) { notification in
            guard events == [] || notification.event != nil && events.contains(notification.event!)
            else { return }
            block(notification)
        }
    }

    // MARK: - KeyPath

    func post<Value>(keyPath: KeyPath<Self, Value>, event: Notification.Event = .changed) {
        post(name: Notification.Name(keyPath: keyPath), event: event)
    }
    
    func addObserver<Value>(
        of keyPath: KeyPath<Self, Value>,
        events: [Notification.Event] = [],
        queue: OperationQueue = OperationQueue.current!,
        using block: @escaping (Notification) -> Void
    ) {
        addObserver(
            ofName: Notification.Name(keyPath: keyPath),
            events: events,
            queue: queue,
            using: block
        )
    }
    
}
