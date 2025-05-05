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

struct NTPTimeInterval {
    let ntpTime: NTPTime
    let interval: TimeInterval
}

@Test(
    "Ensure time intervals are calculated correctly from ntp time",
    arguments: [
        NTPTimeInterval(ntpTime: 0, interval: 0),
        NTPTimeInterval(ntpTime: 16_957_481_510_247_699_044, interval: 3948221334.779565),
    ]
)
func testToInterval(d: NTPTimeInterval) {
    let ntime = NTPTime(d.ntpTime)
    #expect(ntime.toInterval() == d.interval)
}

struct NTPTimeDate {
    let ntpTime: NTPTime
    let date: Date
}

@Test(
    "Ensure dates are calculated correctly from ntp time",
    arguments: [
        // we don't handle era 0 times at all currently.
        // arguably we don't need them for NTP queries.
        // NTPTimeDate(ntpTime: 0, date: Date(timeIntervalSince1970: -NTPTime.unixNTPEpochDelta)),

        // unix epoch
        NTPTimeDate(ntpTime: .ntp1970, date: Date(timeIntervalSince1970: 0)),
        // 1976-07-23 00:38:24 +0000
        NTPTimeDate(ntpTime: NTPTime(10_376_293_541_461_622_784), date: Date(timeIntervalSince1970: 206_930_304)),
        // 2010-08-01 14:15:28 +0000
        NTPTimeDate(ntpTime: NTPTime(14_987_979_559_889_010_688), date: Date(timeIntervalSince1970: 1_280_672_128)),
    ]
)
func testToDate(d: NTPTimeDate) {
    let ntime = NTPTime(d.ntpTime).toDate()
    #expect(ntime == d.date)
}
