import XCTest
@testable import HangulSync

final class TransportPolicyTests: XCTestCase {
    func testDirectNetworkingIsDisabledForThisDeployment() {
        XCTAssertFalse(TransportPolicy.directNetworkingEnabled)
    }

    func testClaimingTrustedOriginOverDirectConnectionIsRejected() {
        for connection in ["in-attacker", "ts-100.64.0.1", "bonjour-peer"] {
            XCTAssertFalse(TransportPolicy.acceptsIncoming(
                origin: "trusted-peer", connectionKey: connection
            ))
        }
    }

    func testRelayIdentityMustMatchAuthenticatedPeer() {
        XCTAssertTrue(TransportPolicy.acceptsIncoming(
            origin: "trusted-peer", connectionKey: "relay-trusted-peer"
        ))
        XCTAssertFalse(TransportPolicy.acceptsIncoming(
            origin: "other-peer", connectionKey: "relay-trusted-peer"
        ))
    }
}
