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
internal import NIOPosix
internal import NTP

#if canImport(FoundationEssentials)
internal import FoundationEssentials
#else
internal import Foundation
#endif

/// Client for querying an NTP server.
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct NTPClient: Sendable {
    public var config: Self.Config

    /// The hostname for the ntp server.
    let server: String

    /// The port for the ntp server.
    let port: Int

    public init(config: Self.Config, server: String, port: Int = 123) {
        self.config = config
        self.server = server
        self.port = port
    }

    /// A configuration object for NTP connection.
    public struct Config: Sendable {
        /// The NTP version to use. Currently only v3 is implemented.
        public var version: NTPVersion

        /// Create a configuration for NTP protocol specifics.
        public init(version: NTPVersion = .v3) {
            self.version = version
        }
    }

    /// Get the first mesasge off the stream and return it.
    ///
    /// - Parameter inbound: the inbound stream to pull the message off of.
    /// - Throws: NTPError.notEnoughBytes when there is no message on the stream.
    /// - Returns: the message off.
    func getResponseFromStream<T>(_ inbound: NIOAsyncChannelInboundStream<T>) async throws -> T {
        var response: T?
        for try await message in inbound {
            response = message
            break
        }

        guard let response else {
            throw NTPError.notEnoughBytes
        }
        return response
    }

    /// NTP query to be sent to the NTP server.
    /// - Parameter timeout: A duration after which the operation will timeout.
    /// - Returns: response from the NTP server with some NTP specific calculations.
    public func query(timeout: Duration) async throws -> NTPResponse {
        let deadlineInstant: ContinuousClock.Instant = ContinuousClock.Instant.now + timeout
        return try await withDeadline(deadlineInstant, clock: ContinuousClock()) {
            let bootstrap = DatagramBootstrap(
                group: MultiThreadedEventLoopGroup.singleton
            ).channelInitializer { channel in
                channel.eventLoop.makeCompletedFuture {
                    try channel.pipeline.syncOperations.configureNTPPipeline()
                }
            }

            let channel: NIOAsyncChannel<NTPResponse, NTPPacket> = try await bootstrap.connect(
                host: self.server,
                port: self.port
            ) { channel in
                channel.eventLoop.makeCompletedFuture {
                    try NIOAsyncChannel<NTPResponse, NTPPacket>(
                        wrappingChannelSynchronously: channel
                    )
                }
            }

            return try await channel.executeThenClose { inbound, outbound in
                var packet = NTPPacket.default
                packet.version = self.config.version.rawValue
                try await outbound.write(packet)
                return try await self.getResponseFromStream(inbound)
            }
        }
    }
}
