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

#if canImport(FoundationEssentials)
internal import FoundationEssentials
#else
internal import Foundation
#endif

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
enum DeadlineFailure: Error {
    case failed(_ failure: Error)
    case timedOut(_ clock: ContinuousClock, _ deadline: ContinuousClock.Instant)
    case cancelled
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
func withDeadline<T: Sendable>(
    _ deadline: ContinuousClock.Instant,
    clock: ContinuousClock,
    _ body: @Sendable () async throws -> T
) async throws -> T {
    let result: Result<T, DeadlineFailure> = await withoutActuallyEscaping(body) { escapingClosure in
        await withTaskGroup(of: Result<T, DeadlineFailure>?.self) { group in
            group.addTask {
                do {
                    try await Task.sleep(until: deadline, clock: clock)
                    return .failure(.timedOut(clock, deadline))
                } catch {
                    return nil
                }
            }

            group.addTask {
                do {
                    let value = try await escapingClosure()
                    return Result<T, DeadlineFailure>.success(value)
                } catch {
                    return Result<T, DeadlineFailure>.failure(DeadlineFailure.failed(error))
                }
            }

            guard let result = await group.next() else {
                return Result<T, DeadlineFailure>.failure(DeadlineFailure.cancelled)
            }
            group.cancelAll()
            return result!  // nil cannot occur here; it has been satisfied by either the sleep or the task
        }
    }

    return try result.get()
}
