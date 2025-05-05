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

    enum Base: Equatable, Hashable {
        case responseNotReceived
        case notEnoughBytes
        case versionNotSupported
    }

    private let base: Base

    init(_ base: Base) { self.base = base }

    /// The client didn't receive a response from the NTP server.
    public static let responseNotReceived = Self(.responseNotReceived)

    /// Received data packet is too small to be a valid NTP response.
    public static let notEnoughBytes = Self(.notEnoughBytes)

    /// NTP version number in the server's response is not supported by the client.
    public static let versionNotSupported = Self(.versionNotSupported)
}
