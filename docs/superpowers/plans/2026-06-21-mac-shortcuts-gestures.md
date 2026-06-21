# macOS Shortcuts & Trackpad Gestures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture voziv-mac's keyboard and trackpad gesture configuration declaratively in the shared `darwin/default.nix` so every host converges to identical behavior.

**Architecture:** All changes are additions to `system.defaults` in `darwin/default.nix` (the module imported by every host). Prefer nix-darwin typed options (`NSGlobalDomain`, `trackpad`, `dock`) — validated at build time, and the typed `trackpad` module writes both plist domains automatically. Use `CustomUserPreferences` only for the few gesture keys with no typed option.

**Tech Stack:** nix-darwin, Determinate Nix, flakes. No test framework — the "test" for each task is a successful `darwin-rebuild build` evaluation. The live `switch` is a manual user step at the end (it mutates the running system and needs sudo).

## Global Constraints

- Two-space indentation; no tabs.
- English only.
- Edit only `darwin/default.nix`; no per-host files (`darwin/hosts/*.nix`) change.
- One intentional deviation from voziv-mac's live state: bottom-right hot corner is set to **disabled** (`1`), not its current Quick Note (`14`).
- Conventional commits: `<type>(<scope>): <subject>`, imperative, ≤50 chars, no period. Split by concern.
- Verification command (the build): `darwin-rebuild build --flake .#voziv-mac` — must succeed and emit `./result`. Clean up with `rm -f result` after.

---

### Task 1: Keyboard — pin F-keys to standard function keys

**Files:**
- Modify: `darwin/default.nix` (the `NSGlobalDomain` block, currently lines ~15-21)

**Interfaces:**
- Consumes: nix-darwin typed option `system.defaults.NSGlobalDomain."com.apple.keyboard.fnState"` (bool).
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Confirm the live value being captured**

Run: `defaults read -g com.apple.keyboard.fnState`
Expected: `1` (this is what we are pinning).

- [ ] **Step 2: Edit `NSGlobalDomain`**

Replace this block:

```nix
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
    };
```

with:

```nix
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      # Use F1/F2/etc. as standard function keys, not media keys.
      "com.apple.keyboard.fnState" = true;
    };
```

- [ ] **Step 3: Build to verify it evaluates**

Run: `darwin-rebuild build --flake .#voziv-mac`
Expected: build succeeds, `./result` symlink created, no eval errors.

- [ ] **Step 4: Clean up the build artifact**

Run: `rm -f result`

- [ ] **Step 5: Commit**

```bash
git add darwin/default.nix
git commit -m "feat(darwin): pin F-keys to standard function keys"
```

---

### Task 2: Trackpad — capture the full gesture set across hosts

**Files:**
- Modify: `darwin/default.nix` (the `NSGlobalDomain` block from Task 1, the `trackpad` block ~lines 36-39, and the `CustomUserPreferences` block ~lines 52-79)

**Interfaces:**
- Consumes: typed options `system.defaults.trackpad.*` (see nix-darwin trackpad module) and `system.defaults.NSGlobalDomain.{"com.apple.trackpad.forceClick",AppleEnableSwipeNavigateWithScrolls}` (bools), plus freeform `system.defaults.CustomUserPreferences`.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Add the two gesture-adjacent keys to `NSGlobalDomain`**

In the `NSGlobalDomain` block (now containing `fnState` from Task 1), add the two lines so it reads:

```nix
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      # Use F1/F2/etc. as standard function keys, not media keys.
      "com.apple.keyboard.fnState" = true;
      # Force Click off; swipe-between-pages with scroll off.
      "com.apple.trackpad.forceClick" = false;
      AppleEnableSwipeNavigateWithScrolls = false;
    };
```

- [ ] **Step 2: Expand the typed `trackpad` block to the full captured set**

Replace this block:

```nix
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
```

with:

```nix
    trackpad = {
      Clicking = true;
      Dragging = false;
      DragLock = false;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
      TrackpadThreeFingerTapGesture = 0; # look-up tap off
      TrackpadCornerSecondaryClick = 0;
      ActuateDetents = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      TrackpadPinch = true; # two-finger zoom
      TrackpadRotate = true;
      TrackpadTwoFingerDoubleTapGesture = true; # smart zoom
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3; # Notification Center
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
    };
```

- [ ] **Step 3: Add the no-typed-option gesture keys to `CustomUserPreferences`**

These keys have no typed nix-darwin option, so write them to both trackpad
plist domains. Add these two attribute sets inside the existing
`system.defaults.CustomUserPreferences = { ... };` block (alongside `pbs` and
`com.apple.symbolichotkeys`):

```nix
    # Trackpad gesture keys with no typed nix-darwin option. Written to both
    # trackpad domains so wired and Bluetooth trackpads stay in sync.
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadFiveFingerPinchGesture = 2;
      TrackpadHandResting = 1;
      TrackpadHorizScroll = 1;
      TrackpadScroll = 1;
      USBMouseStopsTrackpad = 0;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadFiveFingerPinchGesture = 2;
      TrackpadHandResting = 1;
      TrackpadHorizScroll = 1;
      TrackpadScroll = 1;
      USBMouseStopsTrackpad = 0;
    };
```

- [ ] **Step 4: Build to verify it evaluates**

Run: `darwin-rebuild build --flake .#voziv-mac`
Expected: build succeeds, no eval errors (in particular no "option does not
exist" on any `trackpad.*` key — all listed keys are typed in nix-darwin's
trackpad module).

- [ ] **Step 5: Clean up the build artifact**

Run: `rm -f result`

- [ ] **Step 6: Commit**

```bash
git add darwin/default.nix
git commit -m "feat(darwin): manage full trackpad gesture set across hosts"
```

---

### Task 3: Disable the bottom-right hot corner

**Files:**
- Modify: `darwin/default.nix` (the `dock` block, ~lines 23-27)

**Interfaces:**
- Consumes: typed option `system.defaults.dock.wvous-br-corner` (positive int; `1` = Disabled per nix-darwin docs).
- Produces: nothing.

- [ ] **Step 1: Edit the `dock` block**

Replace this block:

```nix
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
    };
```

with:

```nix
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
      # Bottom-right hot corner disabled (was Quick Note, which is unwanted).
      wvous-br-corner = 1;
    };
```

- [ ] **Step 2: Build to verify it evaluates**

Run: `darwin-rebuild build --flake .#voziv-mac`
Expected: build succeeds, no eval errors.

- [ ] **Step 3: Clean up the build artifact**

Run: `rm -f result`

- [ ] **Step 4: Commit**

```bash
git add darwin/default.nix
git commit -m "feat(darwin): disable bottom-right hot corner"
```

---

### Task 4: Cross-host build check and switch handoff

**Files:** none (verification only)

**Interfaces:**
- Consumes: both `darwinConfigurations` (`voziv-mac`, `lrobert-rh`).
- Produces: nothing.

- [ ] **Step 1: Confirm voziv-mac still builds**

Run: `darwin-rebuild build --flake .#voziv-mac`
Expected: success.

- [ ] **Step 2: Confirm the second host evaluates too**

Run: `darwin-rebuild build --flake .#lrobert-rh`
Expected: success (these are shared defaults, so the other host must also
evaluate). If it fails, the error is in the shared block, not host-specific.

- [ ] **Step 3: Clean up**

Run: `rm -f result`

- [ ] **Step 4: Hand off the live switch to the user**

The `switch` mutates the running system and needs sudo, so do not run it
automatically. Tell the user to apply with their `hms` function (which builds,
shows an `nvd diff`, then `sudo darwin-rebuild switch`).

- [ ] **Step 5: Post-switch verification (user runs after `hms`)**

After the user switches, confirm the values landed:

```bash
defaults read -g com.apple.keyboard.fnState                       # -> 1
defaults read com.apple.dock wvous-br-corner                      # -> 1
defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture   # -> 0
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture  # -> 2
```

Note: some trackpad/dock changes only take full effect after a logout/login
(the `Dock` and `cfprefsd` may need to reload), so re-read after re-login if a
value looks stale.

---

## Self-Review

- **Spec coverage:** keyboard `fnState` (Task 1); `forceClick` + `AppleEnableSwipeNavigateWithScrolls` (Task 2 Step 1); full typed trackpad set (Task 2 Step 2); no-typed-option keys on both domains (Task 2 Step 3); hot corner disabled (Task 3); cross-host build + switch handoff + post-switch verification (Task 4). Symbolic hotkey #64 is already declared — out of scope, noted in spec.
- **Placeholder scan:** no TBD/TODO; every code step shows the full block.
- **Type/name consistency:** all `trackpad.*` keys match nix-darwin's typed option names exactly; `wvous-br-corner` uses the typed positive-int option with `1` = Disabled; the three `NSGlobalDomain` keys are confirmed typed.
