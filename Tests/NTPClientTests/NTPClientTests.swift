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

@testable import NTPClient

@Test(
    "Ensure deadline error is thrown",
    .timeLimit(.minutes(1)),  // shortest time limit supported
    arguments: [
        Duration.seconds(0),
        Duration.seconds(1),
    ]
)
func testNTPQueryTimeout(d: Duration) async {
    let ntp = NTPClient(config: .init(), server: "169.254.0.1")
    await #expect(throws: DeadlineFailure.self, "deadline should be thrown in \(d) seconds") {
        let _ = try await ntp.query(timeout: d)
    }
}
