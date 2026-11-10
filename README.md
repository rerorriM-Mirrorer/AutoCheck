# AutoCheck — current-target check (prototype v0.1.1)

Minimal Windower 4 addon: automatically sends FFXI's normal `/check` for the currently selected monster after a short settle delay. It does **not** scan nearby monsters, draw a HUD, alter your target, hide game chat, or display exact monster levels.

## Installation

Copy the entire `AutoCheck` folder into `<Windower4>/addons/`, then type `//lua load AutoCheck`. It starts **on** by default. Type `//ac help` for commands and `//ac status` for the current state.

Common commands: `//ac on`, `//ac off`, `//ac delay 350` (milliseconds), `//ac interval 1.0` (seconds), `//ac memory on`, `//ac memory off`, `//ac reset`, `//ac status`, `//ac restart`, `//ac unload`.

`//ac memory off` is the **default**: checking the same monster again after switching targets is allowed. `//ac memory on` instead remembers checked monster IDs for the duration of the zone. The command is saved per Windower client, including when upgrading from v0.1.0. To install this update, replace the existing `AutoCheck` addon files and reload with `//lua r AutoCheck`.

Settings are saved by Windower's `config` library. Other commands affect this Windower client only.

## Behavior

- Checks monsters only (`spawn_type == 16`, targetable, alive).
- A new target must remain selected for 350 ms by default. Quickly scrolling between monsters cancels previous pending checks.
- At least one second separates all outgoing checks, even when rechecking the same monster after retargeting.
- **Memory OFF (default):** Sends at most one check for each uninterrupted target selection. Switching away and back permits checking that monster again, subject to the same global rate limit. It never loops checks while you hold the same target.
- **Memory ON:** Remembers each checked monster **entity ID** until zoning, logging out, `//ac reset`, or turning memory off. A respawn reusing the same ID may be skipped in this mode until the history clears.
- Revalidates the selected target immediately before sending. No checks during login/logout transitions.
- Sends the game's normal `0x0DD` check packet; native check messages remain visible.
- Checks only monsters within 50 yalms when positions are available; targets farther away are left pending until approached.
- Target-only and client-only. It doesn't send commands to other game clients.

Caution: Automatic packet activity can carry game-policy or account risk. The rate limit is a precaution, not a guarantee.

## Upstream attribution

Based on the check-packet logic and monster filter of [DSGarrett/ImpossibleGauge](https://github.com/DSGarrett/ImpossibleGauge), by Garrett, licensed MIT. The original is unchanged. License text is included in `LICENSE`.

## Status

The v0.1.0 behavior was **confirmed working in FFXI by the user** on 2026-11-09, including at `//ac delay 0`. The v0.1.1 memory option is mock-tested but **not yet live-tested**. See `TESTING.md` for verification and outstanding tests.

## Cumulative changelog

- 2026-11-10 — Initial GitHub development publication. The source was preserved unchanged from the uploaded v0.1.1 package; the recorded mock test added for traceability. `main` is not yet the tested v0.1.0 source.

- 2026-11-09 — v0.1.1: Add persistent `//ac memory on|off` (off by default). When off, recheck a monster upon selecting it again; when on, retain existing once-per-ID-per-zone behavior. Preserve target stabilization and minimum interval; add mode to help/status.
- 2026-11-09 — v0.1.0: Standalone current-target checks, configurable stabilization, one-per-ID-per-zone tracking, rate limiting, target revalidation, original native results, commands, and settings.
