# HangulSync

![HangulSync](../assets/icon-256.png)

[한국어](../README.md) · [Fork repository](https://github.com/entelecheia/HangulSync) · [upstream](https://github.com/catgarret/HangulSync)

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

HangulSync is a macOS menu bar app that reduces separated Hangul jamo (`ㅎㅏㄴㄱㅡㄹ`) during remote desktop use. It keeps the selected input source aligned between two Macs.

This repository is a relay-only fork of [catgarret/HangulSync](https://github.com/catgarret/HangulSync). It does not use direct connections; pairing and sync use explicit invitations and an end-to-end encrypted ntfy.sh relay.

The other language files under `docs/` are legacy upstream documentation. They may describe upstream direct networking, so use this guide for the fork's current behavior.

## How it works

- Input source changes are relayed in both directions.
- If the other Mac has the exact same input source, HangulSync selects it. Otherwise it falls back to an input source in the same language.
- All direct TCP networking is disabled. Bonjour and Tailscale discovery and reconnect are also disabled, and automatic discovery controls are hidden from the UI.
- Pairing and sync use the `https://ntfy.sh` relay. Payloads are end-to-end encrypted between the two Macs.
- This requires internet access and an available ntfy.sh service. Latency depends on the network. ntfy.sh can still see connection, timing, topic, and ciphertext metadata.
- The app stores its own device identity key in the macOS login Keychain.

## Install

This fork has no downloadable release yet. See the [fork Releases page](https://github.com/entelecheia/HangulSync/releases) for future packages; for now, build and install from source on both Macs:

```bash
git clone https://github.com/entelecheia/HangulSync.git
cd HangulSync
./install.sh
```

Requires macOS 13 or later and Xcode Command Line Tools (`xcode-select --install`). This fork does not use direct networking, so no Local Network permission is needed.

## Pair the Macs

Automatic discovery is not available in this fork. Run the app on both Macs, then pair them with an invite:

1. On one Mac, click **Create Invite** and copy the code.
2. On the other Mac, click **Enter Invite** and paste it within two minutes.
3. Confirm that both Macs show the same six-digit confirmation code, then click **Approve** on both.
4. Enable **Always trust this device** if you want automatic reconnects later.
5. Enable **Launch at Login** in settings on both Macs to start the app after login.

After you paste the invite, pairing messages pass through ntfy.sh and are encrypted between the two Macs. If macOS requests Keychain access, confirm that the app is HangulSync and enter your login password only in the system dialog, never in a HangulSync window.

## Remote session option

**Sync Only During Remote Sessions** is enabled by default. It allows sync when a supported remote desktop viewer app is running, such as Jump Desktop, Screen Sharing, Screens, TeamViewer, AnyDesk, or RustDesk. It does not check whether a remote connection is currently established or whether the viewer is frontmost. Turn it off for always-on syncing.

## Menu bar

| Icon | Meaning |
|---|---|
| `⇄한` / `⇄A` | Syncing (current input: Korean / English) |
| `⏸한` / `⏸A` | Paused |
| Dimmed icon | Standby (no supported remote desktop viewer is running) |

The menu shows the number of paired Macs and lets you pause or resume syncing.

## Verification (2026-09-04)

- 16 tests passed.
- A real ntfy.sh smoke test passed for temporary-identity pairing and encrypted messages.
- Two-Mac input-source sync, app restart and reconnect, and Jump Desktop reconnect passed.
- Physical-keyboard Hangul composition was not verified. UI automation changes the input source during synthetic ASCII typing, so that result would not be reliable.

## License

MIT © [dongri.me](https://dongri.me/). This fork retains the upstream MIT license from [catgarret/HangulSync](https://github.com/catgarret/HangulSync).
