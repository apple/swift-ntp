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

import NTPClient
import Testing

@Suite
struct TimeoutTests {
    @Test
    func workCompletes() async throws {
        let expectedValue = "success"

        let result = try await withTimeout(in: .seconds(1), clock: .continuous) {
            expectedValue
        }

        #expect(result == expectedValue)
    }

    @Test
    func workTimesOut() async throws {

        let result = await withThrowingTaskGroup(of: Void.self) { group in
            // Task to run the test
            group.addTask {
                _ = try await withTimeout(in: .seconds(1), clock: .continuous) {
                    // Task that will take longer than the timeout
                    try await Task.sleep(for: .seconds(10), clock: .continuous)
                    Issue.record("Should not be reached")
                }
            }

            return await group.nextResult()
        }
        #expect(throws: TimeOutError.self) {
            try result?.get()
        }
    }

    @Test
    func workThrowsError() async throws {
        struct TestError: Error {
            var message: String
        }
        await #expect(throws: TestError.self) {
            _ = try await withTimeout(in: .seconds(1), clock: .continuous) {
                throw TestError(message: "hi")
            }
        }
    }

    @Test
    func overallCancelled() async throws {
        // Run a task that will not finish for a long time
        let workTask = Task {
            try await withTimeout(in: .seconds(100), clock: .continuous) {
                try await Task.sleep(for: .seconds(10_000))
            }
        }
        // Cancel it
        workTask.cancel()

        // It should throw an error
        await #expect(throws: (any Error).self) {
            try await workTask.value
        }
    }

}
