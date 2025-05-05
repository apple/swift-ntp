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

#if canImport(Darwin)
internal import Darwin
#elseif canImport(Glibc)
internal import Glibc
#elseif canImport(Musl)
internal import Musl
#elseif canImport(Android)
internal import Android
#elseif os(Windows)
internal import ucrt
#else
#error("The NTP module was unable to identify your C library.")
#endif

#if canImport(FoundationEssentials)
package import FoundationEssentials
#else
package import Foundation
#endif

/// A typealias for UInt64 to perform operations
// that are specific to ntp time.
package typealias NTPTime = UInt64

extension NTPTime {
    /// The time between NTP epoch and unix epoch.
    static let unixNTPEpochDelta: Double = 2_208_988_800

    /// The date at which ntp era 1 begins.
    static let ntpEra1Date = Date(timeIntervalSince1970: 2_085_978_496)

    /// The ntp time of the unix epoch.
    static let ntp1970: NTPTime = Self(9_487_534_653_230_284_800)

    /// A way to convert an NTP timestamp to a TimeInterval.
    ///
    /// Since a TimeInterval is just an interval, the notion of
    /// an epoch (ntp, unix or otherwise) is not considered here.
    func toInterval() -> TimeInterval {
        let integer = Double(self >> 32)
        let fraction = Double((self & 0xFFFF_FFFF)) / pow(2.0, 32.0)
        return integer + fraction
    }

    /// Converts the current ntp time to a Date.
    ///
    /// Any dates that are before the unix epoch are assumed to
    /// be in the future.
    ///
    /// - Returns: a date.
    package func toDate() -> Date {
        let time = self.toInterval()

        if self < Self.ntp1970 {
            return Self.ntpEra1Date.addingTimeInterval(time)
        }

        let ret = Date(timeIntervalSince1970: time - Self.unixNTPEpochDelta)
        return ret
    }

    /// Converts between a date object and ntp time.
    ///
    /// - Parameter date: the date which needs to be converted.
    /// - Returns: an ntp timestamp corresponding to the date passed in.
    package static func getNTPTime(_ date: Date) -> NTPTime {
        let unix = date.timeIntervalSince1970
        let integer = UInt64(unix + Self.unixNTPEpochDelta) & 0xffff_ffff
        let fraction = modf(unix).1 * pow(2.0, 32.0)
        return integer << 32 | UInt64(fraction)
    }
}
