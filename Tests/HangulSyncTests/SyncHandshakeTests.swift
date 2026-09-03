import XCTest
@testable import HangulSync

final class SyncHandshakeTests: XCTestCase {
    func testAlwaysOnNoViewerChoosesOneAuthorityForDifferingSources() {
        let local = SyncMessage(
            origin: "mac-a",
            kind: .input,
            sourceID: "com.apple.keylayout.ABC",
            isKorean: false,
            sessionActive: false
        )
        let remote = SyncMessage(
            origin: "mac-b",
            kind: .input,
            sourceID: "com.apple.inputmethod.Korean.2SetKorean",
            isKorean: true,
            sessionActive: false
        )

        XCTAssertNotEqual(local.sourceID, remote.sourceID)
        XCTAssertTrue(SyncHandshakePolicy.allowsInitialState(
            enabled: true,
            onlyDuringRemote: false,
            localViewerActive: false,
            remoteViewerActive: false
        ))
        XCTAssertTrue(SyncHandshakePolicy.localIsInitialAuthority(
            localID: local.origin,
            localViewerActive: false,
            remoteID: remote.origin,
            remoteViewerActive: false
        ))
    }

    func testActiveViewerWinsInitialAuthority() {
        XCTAssertTrue(SyncHandshakePolicy.localIsInitialAuthority(
            localID: "receiver",
            localViewerActive: true,
            remoteID: "sender",
            remoteViewerActive: false
        ))
        XCTAssertFalse(SyncHandshakePolicy.localIsInitialAuthority(
            localID: "receiver",
            localViewerActive: false,
            remoteID: "sender",
            remoteViewerActive: true
        ))
    }

    func testDefaultRemoteOnlyGateRemainsClosedWithoutViewer() {
        XCTAssertFalse(SyncHandshakePolicy.allowsInitialState(
            enabled: true,
            onlyDuringRemote: true,
            localViewerActive: false,
            remoteViewerActive: false
        ))
        XCTAssertTrue(SyncHandshakePolicy.allowsInitialState(
            enabled: true,
            onlyDuringRemote: true,
            localViewerActive: false,
            remoteViewerActive: true
        ))
        XCTAssertFalse(SyncHandshakePolicy.allowsInitialState(
            enabled: false,
            onlyDuringRemote: false,
            localViewerActive: false,
            remoteViewerActive: false
        ))
    }

    func testSenderSessionStateAdmitsInputThatArrivesBeforeSessionPacket() {
        XCTAssertTrue(SyncHandshakePolicy.allowsIncomingInput(
            enabled: true,
            onlyDuringRemote: true,
            localViewerActive: false,
            remoteSessionActive: false,
            senderSessionActive: true
        ))
        XCTAssertFalse(SyncHandshakePolicy.allowsIncomingInput(
            enabled: true,
            onlyDuringRemote: true,
            localViewerActive: false,
            remoteSessionActive: false,
            senderSessionActive: false
        ))
    }

    func testEqualViewerStatesUseOppositeDeterministicDecisions() {
        let first = SyncHandshakePolicy.localIsInitialAuthority(
            localID: "mac-a",
            localViewerActive: false,
            remoteID: "mac-b",
            remoteViewerActive: false
        )
        let second = SyncHandshakePolicy.localIsInitialAuthority(
            localID: "mac-b",
            localViewerActive: false,
            remoteID: "mac-a",
            remoteViewerActive: false
        )

        XCTAssertNotEqual(first, second)
        XCTAssertEqual([first, second].filter { $0 }.count, 1)
    }

    func testEitherPeerCanSubscribeLastAfterTheFirstReadyWasLost() {
        for lastSubscriber in [0, 1] {
            let states = exchange(
                initialSenders: [lastSubscriber], viewers: [false, false]
            )
            XCTAssertEqual(states, ["ABC", "ABC"])
        }
    }

    func testSimultaneousReadinessConvergesWithoutSwappingStatesOrLooping() {
        XCTAssertEqual(exchange(initialSenders: [0, 1], viewers: [false, false]),
                       ["ABC", "ABC"])
    }

    func testActiveViewerWinsRegardlessOfStartupOrder() {
        for lastSubscriber in [0, 1] {
            XCTAssertEqual(exchange(initialSenders: [lastSubscriber], viewers: [false, true]),
                           ["Korean", "Korean"])
        }
    }

    func testHandshakeDoesNotChangeInputWhilePausedOrOutsideRemoteSession() {
        XCTAssertEqual(exchange(initialSenders: [0, 1], viewers: [false, false],
                                onlyDuringRemote: true), ["ABC", "Korean"])
        XCTAssertEqual(exchange(initialSenders: [0, 1], viewers: [false, false],
                                enabled: [true, false]), ["ABC", "Korean"])
    }

    /// Model the targeted ready/input exchange using the same response policy
    /// as SyncEngine. A missing first sender represents publication before the
    /// second subscription existed. A bounded queue catches reply loops.
    private func exchange(
        initialSenders: [Int], viewers: [Bool],
        onlyDuringRemote: Bool = false, enabled: [Bool] = [true, true]
    ) -> [String] {
        let ids = ["mac-a", "mac-b"]
        var sources = ["ABC", "Korean"]
        var queue: [(sender: Int, message: SyncMessage)] = initialSenders
            .filter { enabled[$0] }
            .map { ($0, SyncMessage(origin: ids[$0], kind: .ready,
                                   sessionActive: viewers[$0])) }
        var processed = 0
        while !queue.isEmpty && processed < 12 {
            let (sender, message) = queue.removeFirst()
            let receiver = 1 - sender
            processed += 1
            switch message.kind {
            case .ready:
                switch SyncHandshakePolicy.response(
                    enabled: enabled[receiver], onlyDuringRemote: onlyDuringRemote,
                    localID: ids[receiver], localViewerActive: viewers[receiver],
                    remoteID: ids[sender], remoteViewerActive: message.sessionActive == true
                ) {
                case .none: break
                case .announceReady:
                    queue.append((receiver, SyncMessage(origin: ids[receiver], kind: .ready,
                                                        sessionActive: viewers[receiver])))
                case .sendState:
                    queue.append((receiver, SyncMessage(origin: ids[receiver], kind: .input,
                                                        sourceID: sources[receiver],
                                                        sessionActive: viewers[receiver])))
                }
            case .input:
                if SyncHandshakePolicy.allowsIncomingInput(
                    enabled: enabled[receiver], onlyDuringRemote: onlyDuringRemote,
                    localViewerActive: viewers[receiver], remoteSessionActive: false,
                    senderSessionActive: message.sessionActive
                ) { sources[receiver] = message.sourceID! }
            default: XCTFail("Unexpected handshake message")
            }
        }
        XCTAssertTrue(queue.isEmpty, "Handshake must terminate without an echo loop")
        return sources
    }
}
