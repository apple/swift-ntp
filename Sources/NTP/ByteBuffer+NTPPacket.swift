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
internal import FoundationEssentials
#else
internal import Foundation
#endif

extension ByteBuffer {
    package mutating func readNTPRequestBuffer() -> NTPPacket? {
        guard
            let bytesRead = self.readMultipleIntegers(
                endianness: .big,
                as: (UInt8, UInt8, Int8, Int8, UInt32, UInt32, UInt32, UInt64, UInt64, UInt64, UInt64).self
            )
        else { return nil }
        return .init(
            li: LeapIndicator(rawValue: bytesRead.0 >> 6),
            version: ((bytesRead.0 >> 3) & 0b111),
            mode: NTPMode(rawValue: (bytesRead.0 & 0b111)),
            stratum: bytesRead.1,
            poll: bytesRead.2,
            precision: bytesRead.3,
            rootDelay: bytesRead.4,
            rootDispersion: bytesRead.5,
            referenceID: bytesRead.6,
            referenceTime: bytesRead.7,
            originTime: bytesRead.8,
            receiveTime: bytesRead.9,
            transmitTime: bytesRead.10
        )
    }

    @discardableResult
    package mutating func writeNTPRequestBuffer(_ packet: NTPPacket) -> Int {
        let transmitTime = packet.transmitTime == 0 ? NTPTime.getNTPTime(Date()) : packet.transmitTime
        return self.writeMultipleIntegers(
            NTPPacket.leapVersionMode(packet.li, packet.version, packet.mode),
            packet.stratum,
            packet.poll,
            packet.precision,
            packet.rootDelay,
            packet.rootDispersion,
            packet.referenceID,
            packet.referenceTime,
            packet.originTime,
            packet.receiveTime,
            transmitTime,
            endianness: .big,
            as: (UInt8, UInt8, Int8, Int8, UInt32, UInt32, UInt32, UInt64, UInt64, UInt64, UInt64).self
        )
    }
}
