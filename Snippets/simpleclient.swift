import NTPClient

// snippet.hide
if #available(macOS 13.0, *) {
    // snippet.show

    let ntp = NTPClient(
        config: NTPClient.Config(
            version: .v4
        ),
        server: "time.apple.com"
    )

    let response = try await ntp.query(timeout: .seconds(2))

    print("offset = \(response.offset)")
    print("version = \(response.version.rawValue)")

    // snippet.hide
} else {
    print("use macOS 13 or later to run the snippet")
}
// snippet.show
