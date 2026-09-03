import Foundation

/// Fork transport policy: use the authenticated encrypted relay only.
/// Upstream direct TCP does not prove ownership of a peer's public key.
enum TransportPolicy {
    static let directNetworkingEnabled = false

    static func acceptsIncoming(origin: String, connectionKey: String) -> Bool {
        connectionKey == "relay-\(origin)"
    }
}
