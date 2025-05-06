# swift-ntp

`swift-ntp` provides a Network Time Protocol (NTP) client that can be used to asynchronously synchronize clocks on the network.

## Overview

This library provides a client that partially implements NTP v3 (RFC 1305). It also comes with limited support for NTP v4 (RFC 5905).

### Library Structure

This repository contains two main library products:

* `NTPClient`: Provides the high-level `NTPClient`. This is intended for consumption by other projects.
  * [NTPClient documentation](https://swiftpackageindex.com/apple/swift-ntp/documentation/ntpclient)
* `NTP`: (`package` level) Contains the core NTP protocol logic, packet parsing/serialization, and data structures. It is currently not publicly accessible.

## 💻 Examples

Examples can be found in the [Snippets](Snippets) directory.

```swift
// Instantiate the NTP Client
let ntp = NTPClient(
    config: NTPClient.Config(
        version: .v4 // Ensure the use of NTPv4.
    ),
    server: "time.apple.com", // Configure the time source.
)

// Asynchronously query the time source
let response = try await ntp.query(timeout: .seconds(2))

// Get clock offset.
print("offset = \(response.offset)")
```

## 🚀 Contributing

Contributions are welcome! Take a look at [CONTRIBUTING.md](CONTRIBUTING.md)
to learn how.

## 🔒 Security

Security issues should be reported via the process in [SECURITY.md](SECURITY.md).

## 🪪 License

The project is licensed under Apache 2.0 license repeated in [LICENSE.txt](LICENSE.txt).
