import Foundation

/// Chooses one peer to publish the first state after a relay subscription is ready.
/// An active remote viewer owns the initial state; equal viewer states use a stable
/// device-ID order. A follower echoes readiness so a later authority can respond
/// even when the follower's earlier announcement had no subscriber yet.
enum SyncHandshakePolicy {
    enum Response {
        case none
        case announceReady
        case sendState
    }

    static func response(
        enabled: Bool,
        onlyDuringRemote: Bool,
        localID: String,
        localViewerActive: Bool,
        remoteID: String,
        remoteViewerActive: Bool
    ) -> Response {
        guard localID != remoteID, allowsInitialState(
            enabled: enabled,
            onlyDuringRemote: onlyDuringRemote,
            localViewerActive: localViewerActive,
            remoteViewerActive: remoteViewerActive
        ) else { return .none }
        return localIsInitialAuthority(
            localID: localID,
            localViewerActive: localViewerActive,
            remoteID: remoteID,
            remoteViewerActive: remoteViewerActive
        ) ? .sendState : .announceReady
    }

    static func allowsInitialState(
        enabled: Bool,
        onlyDuringRemote: Bool,
        localViewerActive: Bool,
        remoteViewerActive: Bool
    ) -> Bool {
        guard enabled else { return false }
        guard onlyDuringRemote else { return true }
        return localViewerActive || remoteViewerActive
    }

    static func allowsIncomingInput(
        enabled: Bool,
        onlyDuringRemote: Bool,
        localViewerActive: Bool,
        remoteSessionActive: Bool,
        senderSessionActive: Bool? = nil
    ) -> Bool {
        guard enabled else { return false }
        guard onlyDuringRemote else { return true }
        return localViewerActive || remoteSessionActive || senderSessionActive == true
    }

    static func localIsInitialAuthority(
        localID: String,
        localViewerActive: Bool,
        remoteID: String,
        remoteViewerActive: Bool
    ) -> Bool {
        if localViewerActive != remoteViewerActive {
            return localViewerActive
        }
        return localID < remoteID
    }
}
