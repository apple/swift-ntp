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

import Testing

@testable import NTP

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct LiVersMode {
    let li: LeapIndicator
    let version: UInt8
    let mode: NTPMode
    let expected: UInt8
}

@Test(
    "Ensure serialization of leap, version and mode",
    arguments: [
        LiVersMode(
            li: .noAdjustment,
            version: 3,
            mode: .client,
            expected: 27
        ),
        LiVersMode(
            li: .unsynchronized,
            version: 3,
            mode: .client,
            expected: 219
        ),
        LiVersMode(
            li: .noAdjustment,
            version: 3,
            mode: .server,
            expected: 28
        ),
    ]
)
func testLiVersMode(d: LiVersMode) async throws {
    #expect(
        NTPPacket.leapVersionMode(d.li, d.version, d.mode) == d.expected
    )
}

struct OffsetTestData {
    let originTime: UInt64
    let serverReceiveTime: UInt64
    let transmitTime: UInt64
    let clientReceiveTime: UInt64
    let expected: TimeInterval
}

@Test(
    "Ensure offset is accurate",
    arguments: [
        OffsetTestData(
            originTime: 0,
            serverReceiveTime: 0,
            transmitTime: 0,
            clientReceiveTime: 0,
            expected: 0
        ),
        OffsetTestData(
            originTime: 16_957_481_510_247_699_044,
            serverReceiveTime: 16_957_481_510_448_892_874,
            transmitTime: 16_957_481_510_449_064_990,
            clientReceiveTime: 16_957_481_510_381_566_913,
            expected: 0.03127985494211316
        ),
        OffsetTestData(
            originTime: 16_957_530_816_944_033_792,
            serverReceiveTime: 16_957_530_902_843_379_712,  // origin + 20 seconds
            transmitTime: 16_957_530_907_138_347_008,  // origin + 21 seconds
            clientReceiveTime: 16_957_530_838_418_870_272,  // origin + 05 seconds
            expected: 18
        ),
        OffsetTestData(
            originTime: 16_957_536_211_640_536_064,
            serverReceiveTime: 16_957_536_215_935_503_360,  // origin + 1 seconds
            transmitTime: 16_957_536_220_230_470_656,  // origin + 2 seconds
            clientReceiveTime: 16_957_536_228_820_405_248,  // origin + 4 seconds
            expected: -0.5
        ),
    ]
)
func testOffset(d: OffsetTestData) {
    let p = NTPPacket(
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
        originTime: d.originTime,
        receiveTime: d.serverReceiveTime,
        transmitTime: d.transmitTime
    )
    #expect(
        p.getOffset(clientReceiveTime: d.clientReceiveTime) == d.expected
    )
}
