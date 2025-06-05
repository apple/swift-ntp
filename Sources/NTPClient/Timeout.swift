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

private enum TaskResult<T: Sendable>: Sendable {
    case success(T)
    case error(any Error)
    case timedOut
    case cancelled
}

package struct TimeOutError: Error, CustomStringConvertible, CustomDebugStringConvertible {
    var underlying: any Error

    package var description: String {
        "TimeOutError(\(String(describing: underlying))"
    }

    package var debugDescription: String {
        description
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
package func withTimeout<T: Sendable, Clock: _Concurrency.Clock>(
    in timeout: Clock.Duration,
    clock: Clock,
    isolation: isolated (any Actor)? = #isolation,
    body: sending @escaping @isolated(any) () async throws -> T
) async throws -> T {
    // This is needed so we can make body sending since we don't have call-once closures yet
    let body = { body }
    let result: Result<T, any Error> = await withTaskGroup(of: TaskResult<T>.self) { group in
        let body = body()
        group.addTask {
            do {
                return .success(try await body())
            } catch {
                return .error(error)
            }
        }
        group.addTask {
            do {
                try await clock.sleep(for: timeout, tolerance: .zero)
                return .timedOut
            } catch {
                return .cancelled
            }
        }

        switch await group.next() {
        case .success(let result):
            // Work returned a result. Cancel the timer task and return
            group.cancelAll()
            return .success(result)
        case .error(let error):
            // Work threw. Cancel the timer task and rethrow
            group.cancelAll()
            return .failure(error)
        case .timedOut:
            // Timed out, cancel the work task.
            group.cancelAll()

            switch await group.next() {
            case .success(let result):
                return .success(result)
            case .error(let error):
                return .failure(TimeOutError(underlying: error))
            case .timedOut, .cancelled, .none:
                // We already got a result from the sleeping task so we can't get another one or none.
                fatalError("Unexpected task result")
            }
        case .cancelled:
            switch await group.next() {
            case .success(let result):
                return .success(result)
            case .error(let error):
                return .failure(TimeOutError(underlying: error))
            case .timedOut, .cancelled, .none:
                // We already got a result from the sleeping task so we can't get another one or none.
                fatalError("Unexpected task result")
            }
        case .none:
            fatalError("Unexpected task result")
        }
    }
    return try result.get()
}
