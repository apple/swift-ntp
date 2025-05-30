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

/// Errors thrown during NTP operations.
public struct NTPError: Error, Equatable, Hashable, CustomStringConvertible {
    public var description: String {
        String(describing: self.base)
    }

    @usableFromInline
    enum Base: Equatable, Hashable, Sendable {
        case responseNotReceived
        case notEnoughBytes
        case versionNotSupported
    }

    @usableFromInline
    let base: Base

    @inlinable
    init(_ base: Base) { self.base = base }

    /// The client didn't receive a response from the NTP server.
    @inlinable
    public static var responseNotReceived: Self {
        Self(.responseNotReceived)
    }

    /// Received data packet is too small to be a valid NTP response.
    @inlinable
    public static var notEnoughBytes: Self {
        Self(.notEnoughBytes)
    }

    /// NTP version number in the server's response isn't supported by the client.
    @inlinable
    public static var versionNotSupported: Self {
        Self(.versionNotSupported)
    }
}
