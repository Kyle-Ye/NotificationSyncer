//
//  NotificitionSyncerCombiner.swift
//  NotificationSyncer
//
//  Created by Kyle on 2024/10/25.
//

import Foundation

public struct NotificitionSyncerCombiner<A, B>: NotificitionSyncer where A: NotificitionSyncer, B: NotificitionSyncer {
    public struct Value: SyncableValue {
        public let a: A.Value?
        public let b: B.Value?
        
        public init(_ a: A.Value?, _ b: B.Value?) {
            self.a = a
            self.b = b
        }
        
        public init?(userInfo: [AnyHashable: Any]) {
            let a = A.Value(userInfo: userInfo)
            let b = B.Value(userInfo: userInfo)
            if a == nil && b == nil { return nil }
            self.a = a
            self.b = b
        }
        
        public var userInfo: [AnyHashable: Any] {
            if let a = a, let b = b {
                return a.userInfo.merging(b.userInfo) { $1 }
            } else if let a {
                return a.userInfo
            } else if let b {
                return b.userInfo
            } else {
                return [:]
            }
        }
    }
    
    public static var center: NotificationCenter { A.center }
    
    public static var name: Notification.Name { fatalError() }
    
    public static func register<T>(_ delegate: T) where T: NotificitionSyncerDelegate<Self> {
        center.addObserver(delegate, selector: #selector(T.handleSyncerNotification(_:)), name: A.name, object: nil)
        center.addObserver(delegate, selector: #selector(T.handleSyncerNotification(_:)), name: B.name, object: nil)
    }
    
    public static func post(value: Value, object: Any?) {
        if let a = value.a {
            A.post(value: a, object: object)
        }
        if let b = value.b {
            B.post(value: b, object: object)
        }
    }
}

extension NotificitionSyncer {
    public static func combine<Other>(_ other: Other.Type = Other.self) -> NotificitionSyncerCombiner<Self, Other>.Type where Other: NotificitionSyncer {
        NotificitionSyncerCombiner<Self, Other>.self
    }
}
