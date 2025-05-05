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

internal import NTP

#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

/// A response created from an ntp packet that is received from an NTP server.
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct NTPResponse: Sendable, Hashable {

    /// The calculated clock offset between the client and the server.
    ///
    /// This value represents the time difference that should be applied
    /// to the client's clock to synchronize it with the server's time,
    /// according to the NTP specification calculations. It is represented
    /// as a `Duration`.
    public var offset: Duration

    /// The calculated round-trip delay for the NTP request/response exchange.
    public var roundTripDelay: Duration

    /// The server's time when the response packet was transmitted.
    public var serverTime: Date

    /// The version of the ntp protocol being used
    /// Currently only version 3 is implemented.
    public var version: NTPVersion

    /// Indicates whether a leap second adjustment is imminent.
    public var leapIndicator: LeapIndicator

    /// The stratum level of the server.
    public var stratum: UInt8

    /// The precision of the server's clock.
    public var precision: Int8

    /// An identifier for the server's reference clock source.
    public var referenceID: UInt32

    /// The time when the server's system clock was last set or corrected.
    public var referenceTime: Date

    /// The total round-trip delay to the primary reference source
    public var rootDelay: UInt32

    /// The maximum error relative to the primary reference source.
    public var rootDispersion: UInt32

    public init(
        offset: Duration,
        roundTripDelay: Duration,
        serverTime: Date,
        version: NTPVersion,
        leapIndicator: LeapIndicator,
        stratum: UInt8,
        precision: Int8,
        referenceID: UInt32,
        referenceTime: Date,
        rootDelay: UInt32,
        rootDispersion: UInt32
    ) {
        self.offset = offset
        self.roundTripDelay = roundTripDelay
        self.serverTime = serverTime
        self.version = version
        self.leapIndicator = leapIndicator
        self.stratum = stratum
        self.precision = precision
        self.referenceID = referenceID
        self.referenceTime = referenceTime
        self.rootDelay = rootDelay
        self.rootDispersion = rootDispersion
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension NTPResponse {
    init(_ p: NTPPacket, clientReceiveTime: NTPTime = .getNTPTime(Date())) throws {
        guard let version = NTPVersion(p.version) else {
            throw NTPError.versionNotSupported
        }

        self.init(
            offset: .seconds(p.getOffset(clientReceiveTime: clientReceiveTime)),
            roundTripDelay: .seconds(p.getRoundTripDelay(clientReceiveTime: clientReceiveTime)),
            serverTime: NTPTime(p.transmitTime).toDate(),
            version: version,
            leapIndicator: LeapIndicator(rawValue: p.li.rawValue),
            stratum: p.stratum,
            precision: p.precision,
            referenceID: p.referenceID,
            referenceTime: p.referenceTime.toDate(),
            rootDelay: p.rootDelay,
            rootDispersion: p.rootDispersion
        )
    }
}

/// Represents the leap indicator from the NTP spec.
public struct LeapIndicator: RawRepresentable, Sendable, Hashable {

    /// The raw underlying value representing the leap indicator code.
    ///
    /// - `0`: No adjustment.
    /// - `1`: Last minute of the day has 61 seconds (positive leap second).
    /// - `2`: Last minute of the day has 59 seconds (negative leap second).
    /// - `3`: Clock is unsynchronized.
    ///
    /// While you can access this value directly, prefer using the static constants
    /// like `.noAdjustment`, `.addSecond`, etc.
    public var rawValue: UInt8

    /// Indicates no leap second adjustment is scheduled for the current day.
    ///
    /// Corresponds to a `rawValue` of 0.
    public static let noAdjustment = Self(rawValue: 0)

    /// Indicates the server will add a positive leap second at the end of the current day (UTC).
    ///
    /// Corresponds to a `rawValue` of 1.
    public static let addSecond = Self(rawValue: 1)

    /// Indicates that a leap second will be subtracted at the end of the current day (UTC).
    ///
    /// Corresponds to a `rawValue` of 2.
    public static let subtractSecond = Self(rawValue: 2)

    /// Indicates that the time source is unsynchronized.
    ///
    /// The time information should not be considered reliable.
    /// Corresponds to a `rawValue` of 3.
    public static let unsynchronized = Self(rawValue: 3)

    /// Creates a new `LeapIndicator` instance from a raw value.
    ///
    /// - Parameter rawValue: The raw value representing the leap indicator state.
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
