//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2025 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// The version number of the Network Time Protocol (NTP).
///
/// This struct provides a type-safe way to handle v3 (partial support)
/// and v4 (limited support).
public struct NTPVersion: Hashable, Sendable {

    fileprivate enum Version: UInt8, Equatable, Hashable, Sendable {
        case v3 = 3
        case v4 = 4
    }

    /// The stored NTP version case.
    private let version: Version

    private init(_ version: Version) {
        self.version = version
    }

    /// Creates a version from the raw value you provide, or nil if the value is unsupported.
    ///
    /// The optional initializer fails if the value you provide for `version` is not a supported NTP version.
    /// number is not a supported NTP version.
    ///
    /// - Parameter version: The raw NTP version number (for example, `3` or `4`).
    public init?(_ version: UInt8) {
        switch version {
        case 3:
            self = .v3
        case 4:
            self = .v4
        default:
            return nil
        }
    }

    /// The Network Time Protocol version 3.
    public static let v3 = Self(.v3)

    /// The Network Time Protocol version 4.
    ///
    /// - Note: While this version constant exists, it is provided to provide
    ///   backwards-compatible features with v3.
    public static let v4 = Self(.v4)
}

extension NTPVersion {
    /// The raw value that represents the NTP version (for example, `3` or `4`).
    public var rawValue: UInt8 {
        get {
            switch self.version {
            case .v3: return 3
            case .v4: return 4
            }
        }
    }
}
