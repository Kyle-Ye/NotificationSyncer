//
//  SyncValueCodable.swift
//
//
//  Created by Kyle on 2024/10/25.
//

public protocol SyncValueCodable {
    init?(userInfo: [AnyHashable: Any])
    var userInfo: [AnyHashable: Any] { get }
}
