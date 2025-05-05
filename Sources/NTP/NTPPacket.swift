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

internal import NIOCore

#if canImport(FoundationEssentials)
package import FoundationEssentials
#else
package import Foundation
#endif

package struct NTPMode: RawRepresentable, Sendable, Hashable {
    package var rawValue: UInt8

    static let reserved = Self(rawValue: 0)
    static let symmetricActive = Self(rawValue: 1)
    static let symmetricPassive = Self(rawValue: 2)
    static let client = Self(rawValue: 3)
    static let server = Self(rawValue: 4)
    static let broadcast = Self(rawValue: 5)
    static let controlMessage = Self(rawValue: 6)
    static let reservedPrivate = Self(rawValue: 7)

    package init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

package struct LeapIndicator: RawRepresentable, Sendable, Hashable {
    package var rawValue: UInt8

    package static let noAdjustment = Self(rawValue: 0)
    package static let addSecond = Self(rawValue: 1)
    package static let subtractSecond = Self(rawValue: 2)
    package static let unsynchronized = Self(rawValue: 3)

    package init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

package struct NTPPacket: Sendable, Hashable {
    package init(
        li: LeapIndicator,
        version: UInt8,
        mode: NTPMode,
        stratum: UInt8,
        poll: Int8,
        precision: Int8,
        rootDelay: UInt32,
        rootDispersion: UInt32,
        referenceID: UInt32,
        referenceTime: UInt64,
        originTime: UInt64,
        receiveTime: UInt64,
        transmitTime: UInt64
    ) {
        self.li = li
        self.version = version
        self.mode = mode
        self.stratum = stratum
        self.poll = poll
        self.precision = precision
        self.rootDelay = rootDelay
        self.rootDispersion = rootDispersion
        self.referenceID = referenceID
        self.referenceTime = referenceTime
        self.originTime = originTime
        self.receiveTime = receiveTime
        self.transmitTime = transmitTime
    }

    /// leap indicator
    package var li: LeapIndicator
    package var version: UInt8
    package var mode: NTPMode

    package var stratum: UInt8
    package var poll: Int8
    package var precision: Int8
    package var rootDelay: UInt32
    package var rootDispersion: UInt32

    // reference id, which is also KoD code if stratum is 0
    package var referenceID: UInt32

    package var referenceTime: UInt64
    package var originTime: UInt64
    package var receiveTime: UInt64
    package var transmitTime: UInt64
}

extension NTPPacket {
    package static let `default` = NTPPacket(
        li: .noAdjustment,
        version: 3,
        mode: .client,
        stratum: 0,
        poll: 0,
        precision: 0x20,
        rootDelay: 0,
        rootDispersion: 0,
        referenceID: 0,
        referenceTime: 0,
        originTime: 0,
        receiveTime: 0,
        transmitTime: 0
    )
}

extension NTPPacket {
    static func leapVersionMode(_ li: LeapIndicator, _ version: UInt8, _ mode: NTPMode) -> UInt8 {
        var mutableLIVM: UInt8 = 0
        mutableLIVM = (mutableLIVM & 0xc7) | UInt8(version) << 3
        mutableLIVM = (mutableLIVM & 0xf8) | UInt8(mode.rawValue)
        mutableLIVM = (mutableLIVM & 0x3f) | UInt8(li.rawValue) << 6
        return mutableLIVM
    }

    package func getOffset(clientReceiveTime: UInt64) -> TimeInterval {
        let a = Int64(bitPattern: self.receiveTime) - Int64(bitPattern: self.originTime)
        let b = Int64(bitPattern: self.transmitTime) - Int64(bitPattern: clientReceiveTime)
        let offset = a + (b - a) / 2
        if offset < 0 {
            return -1 * NTPTime(-1 * offset).toInterval()
        }
        return NTPTime(offset).toInterval()
    }

    package func getRoundTripDelay(clientReceiveTime: UInt64) -> TimeInterval {
        let clientNTPDate = NTPTime(clientReceiveTime).toDate()
        let a = clientNTPDate.timeIntervalSince(self.originTime.toDate())
        let b = self.transmitTime.toDate().timeIntervalSince(self.receiveTime.toDate())
        var roundTripDelay = a - b
        if roundTripDelay < 0 {
            roundTripDelay = 0
        }
        return roundTripDelay
    }
}
