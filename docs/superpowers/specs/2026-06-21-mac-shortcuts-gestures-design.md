# macOS keyboard shortcuts & trackpad gestures in nix-darwin

**Date:** 2026-06-21
**Status:** Approved (design)

## Goal

Capture this Mac's (`voziv-mac`) keyboard and trackpad gesture configuration
declaratively and apply it to **all** hosts for consistency. Settings live in the
shared `darwin/default.nix` so every `darwin-rebuild` host converges to the same
behavior regardless of its prior manual state.

## Findings (from live `defaults` on voziv-mac)

Keyboard customization is effectively empty:

- No modifier-key remaps (`com.apple.keyboard.modifiermapping` unset, `hidutil`
  returns null).
- No custom app menu shortcuts (`NSGlobalDomain.NSUserKeyEquivalents` unset).
- No customized symbolic hotkeys except `#64` (Spotlight "Show Finder search
  window", CMD+Shift+A), which is **already disabled** in `darwin/default.nix`.
- One genuine delta: `com.apple.keyboard.fnState = 1` (F-keys behave as standard
  function keys; macOS default is media keys).

Trackpad has a rich gesture set; nix currently manages only `Clicking` and
`TrackpadThreeFingerDrag`.

## Design decisions

- **Scope:** shared `darwin/default.nix` only. No per-host files change.
- **Coverage:** declare the *full* trackpad gesture set (including keys at macOS
  defaults) so any host converges identically — not just deltas.
- **Mechanism:** prefer nix-darwin *typed* options (`system.defaults.trackpad`,
  `system.defaults.NSGlobalDomain`, `system.defaults.dock`). They are validated at
  build time and the typed `trackpad` module writes to **both** plist domains
  (`com.apple.AppleMultitouchTrackpad` and
  `com.apple.driver.AppleBluetoothMultitouch.trackpad`) automatically. Use
  `CustomUserPreferences` (on both domains) only for the few gesture keys that have
  no typed option. Rejected alternative: putting everything in raw
  `CustomUserPreferences`, which loses build-time validation and the automatic
  dual-domain write.
- **Hot corner:** capture it, but **disabled** — the user finds the current
  bottom-right Quick Note action annoying. `wvous-br-corner = 1` (nix-darwin's
  documented "Disabled" value). This is the one intentional change from the live
  value (`14` = Quick Note).

## Changes to `darwin/default.nix`

### 1. Keyboard — `NSGlobalDomain`

Add to the existing `NSGlobalDomain` block:

- `"com.apple.keyboard.fnState" = true;` — F-keys as standard function keys.
- `"com.apple.trackpad.forceClick" = false;` — Force Click off (live value 0).
- `AppleEnableSwipeNavigateWithScrolls = false;` — swipe-between-pages off (live 0).

(`fnState` is keyboard; the latter two are gesture-adjacent but live in
`NSGlobalDomain`, so they are grouped here.)

The existing symbolic-hotkey `#64` disable stays unchanged.

### 2. Trackpad — expand typed `system.defaults.trackpad`

Replace the current two-key block with the complete captured set:

| Key | Value | Meaning |
| --- | --- | --- |
| `Clicking` | `true` | tap to click |
| `Dragging` | `false` | tap-to-drag off |
| `DragLock` | `false` | drag lock off |
| `TrackpadRightClick` | `true` | two-finger secondary click |
| `TrackpadThreeFingerDrag` | `true` | three-finger drag |
| `TrackpadThreeFingerTapGesture` | `0` | look-up tap **off** |
| `TrackpadCornerSecondaryClick` | `0` | corner secondary click off |
| `ActuateDetents` | `true` | haptic feedback |
| `FirstClickThreshold` | `1` | medium |
| `SecondClickThreshold` | `1` | medium |
| `TrackpadPinch` | `true` | two-finger zoom |
| `TrackpadRotate` | `true` | two-finger rotate |
| `TrackpadTwoFingerDoubleTapGesture` | `true` | smart zoom |
| `TrackpadTwoFingerFromRightEdgeSwipeGesture` | `3` | Notification Center |
| `TrackpadThreeFingerHorizSwipeGesture` | `2` | swipe between full-screen apps |
| `TrackpadThreeFingerVertSwipeGesture` | `2` | Mission Control / App Exposé |
| `TrackpadFourFingerHorizSwipeGesture` | `2` | swipe between full-screen apps |
| `TrackpadFourFingerVertSwipeGesture` | `2` | Mission Control / App Exposé |
| `TrackpadFourFingerPinchGesture` | `2` | Desktop / Launchpad pinch |

### 3. Trackpad keys with no typed option — `CustomUserPreferences`

Written to **both** trackpad domains (`com.apple.AppleMultitouchTrackpad` and
`com.apple.driver.AppleBluetoothMultitouch.trackpad`):

- `TrackpadFiveFingerPinchGesture = 2`
- `TrackpadHandResting = 1`
- `TrackpadHorizScroll = 1`
- `TrackpadScroll = 1`
- `USBMouseStopsTrackpad = 0`

### 4. Hot corner — `system.defaults.dock`

- `"wvous-br-corner" = 1;` — bottom-right corner **disabled** (was Quick Note).

## Verification

1. `darwin-rebuild build --flake .#voziv-mac` — evaluation/build succeeds.
2. After `hms` switch, re-read the domains and confirm values match:
   - `defaults read com.apple.AppleMultitouchTrackpad`
   - `defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad`
   - `defaults read -g com.apple.keyboard.fnState` → `1`
   - `defaults read com.apple.dock wvous-br-corner` → `1`
3. Sanity-check the second host evaluates: `darwin-rebuild build --flake .#lrobert-rh`.

## Out of scope

- Modifier remapping, app menu shortcuts, and Mission Control/Spotlight hotkey
  customization (none exist to capture).
- Third-party shortcut managers (LinearMouse, Ice, JetBrains).
- `MAC.md` documentation update (optional follow-up, can note these are now
  declarative).
