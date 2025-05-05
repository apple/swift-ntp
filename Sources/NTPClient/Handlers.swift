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
internal import NTP

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
final class NTPHandler: ChannelDuplexHandler, Sendable {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias InboundOut = NTPResponse
    typealias OutboundIn = NTPPacket
    typealias OutboundOut = ByteBuffer

    static let shared = NTPHandler()

    private init() {}

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buf = self.unwrapInboundIn(data)
        guard let p = buf.data.readNTPRequestBuffer() else {
            context.fireErrorCaught(NTPError.notEnoughBytes)
            return
        }
        var response: NTPResponse
        do {
            response = try NTPResponse(p)
        } catch {
            context.fireErrorCaught(
                NTPError.versionNotSupported
            )
            return
        }
        context.fireChannelRead(self.wrapInboundOut(response))
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let packet = self.unwrapOutboundIn(data)
        var buffer = context.channel.allocator.buffer(capacity: 64)
        buffer.writeNTPRequestBuffer(packet)
        context.write(
            Self.wrapOutboundOut(buffer),
            promise: promise
        )
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension ChannelPipeline.SynchronousOperations {
    func configureNTPPipeline() throws {
        try self.addHandler(NTPHandler.shared)
    }
}
