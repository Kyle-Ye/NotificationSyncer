//
//  NotificationSyncer.swift
//
//
//  Created by Kyle on 2024/10/25.
//

import Foundation

public protocol NotificitionSyncer<Value> {
    associatedtype Value: SyncableValue
    static var center: NotificationCenter { get }
    static var name: Notification.Name { get }
    
    static func register(_ delegate: some NotificitionSyncerDelegate<Self>)
    static func value(for notification: Notification) -> Value?
    static func post(value: Value, object: Any?)
}

public protocol NotificitionSyncerDelegate<Syncer>: _NotificitionHandable {
    associatedtype Syncer: NotificitionSyncer
    func syncerValueChanged(_ value: Syncer.Value)
}

extension NotificitionSyncerDelegate {
    /// Selector need ObjC protocol and ObjC protocol does not support default implementaiton
    public func defaultHandleSyncerNotification(_ notification: Notification) {
        guard let value = Syncer.value(for: notification) else { return }
        syncerValueChanged(value)
    }
}

@objc
public protocol _NotificitionHandable {
    func handleSyncerNotification(_ notification: Notification)
}

extension NotificitionSyncer {
    public static var center: NotificationCenter { .default }
    
    public static func register<T>(_ delegate: T) where T: NotificitionSyncerDelegate<Self> {
        center.addObserver(delegate, selector: #selector(T.handleSyncerNotification(_:)), name: name, object: nil)
    }
    
    public static func value(for notification: Notification) -> Value? {
        guard let userInfo = notification.userInfo else {
            return nil
        }
        return Value(userInfo: userInfo)
    }
    
    public static func post(value: Value) {
        post(value: value, object: nil)
    }
    
    public static func post(value: Value, object: Any?) {
        center.post(name: name, object: object, userInfo: value.userInfo)
    }
}
