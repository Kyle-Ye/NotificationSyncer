//
//  SyncableValue.swift
//
//
//  Created by Kyle on 2024/10/25.
//

public protocol SyncableValue {
    init?(userInfo: [AnyHashable: Any])
    var userInfo: [AnyHashable: Any] { get }
}

private enum SyncableValueKey: String, CodingKey {
    case userInfo = "user_info"
}

// MARK: - CoddleBySyncableValue

public protocol CoddleBySyncableValue: Codable, SyncableValue {}

extension CoddleBySyncableValue {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: SyncableValueKey.self)
        var encoded: [String: String] = [:]
        for (key, value) in userInfo {
            encoded[key.description] = String(describing: value)
        }
        try container.encode(encoded, forKey: .userInfo)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: SyncableValueKey.self)
        let userInfo = try container.decode([String: String].self, forKey: .userInfo)
        if let value = Self(userInfo: userInfo) {
            self = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid data"))
        }
    }
}

// MARK: - SyncValueCodable

@propertyWrapper
public struct SyncValueCodable<Value>: Codable where Value: SyncableValue {
    public var wrappedValue: Value
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: SyncableValueKey.self)
        var encoded: [String: String] = [:]
        for (key, value) in wrappedValue.userInfo {
            encoded[key.description] = String(describing: value)
        }
        try container.encode(encoded, forKey: .userInfo)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: SyncableValueKey.self)
        let userInfo = try container.decode([String: String].self, forKey: .userInfo)
        if let value = Value(userInfo: userInfo) {
            wrappedValue = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid data"))
        }
    }
}
