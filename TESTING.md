# Current Development Status — 2026-11-10, GitHub development import

- **Repository/branch:** `rerorriM-Mirrorer/AutoCheck` / `development/memory-toggle`. `main` remains a documentation-only placeholder because the earlier user-tested v0.1.0 source was not provided in this ZIP. Do not describe the v0.1.1 memory behavior as live-tested.
- **Source checkpoint:** user-provided `AutoCheck-v0.1.1-memory-toggle(1).zip` (SHA-256 `aab5d71d47951db39ac289b5ba466ef669b58bdcc6ad315e78f170a26eee85fc`). Its `AutoCheck.lua` is imported byte-for-byte; original local Git commit ancestry is unavailable from the ZIP.
- **Last live-accepted behavior:** the user confirmed the earlier v0.1.0 automatic current-target check worked, even at delay 0, on 2026-11-09. That does not validate the new memory option.
- **Publication checks:** Lua 5.4 parsed the unchanged `AutoCheck.lua` and the newly included `tests/run.lua`; a new deterministic mocked Windower test passed basic packet fields, default memory OFF, repeated-target handling, memory ON/OFF and rate-limiting. No native Lua 5.1/LuaJIT or Windows/FFXI live tests ran. This is not a reconstruction of the source ZIP's historical mock test harness.
- **Live acceptance still needed:** `//ac status`, A→B→A with memory OFF/ON, reselect, reload persistence, and native check result responses. `main` should receive the exact accepted source only after a user test or recovery of the historical v0.1.0 source.
- **Install:** use the full development branch source as the `Windower4/addons/AutoCheck/` directory, preserving existing `data/`. Never run both TellLevel's optional `autocheck` and standalone AutoCheck simultaneously unless intentionally configured.

---

# AutoCheck testing record

## Current Development Status — 2026-11-09 (v0.1.1 memory option)

- **Repository / branch:** Local source reconstructed from the delivered v0.1.0 ZIP / `dev/memory-toggle`. No remote configured. Starting, user-tested package imported to local Git as `959139d`; previous-turn mention of an earlier local commit `906c1ce` cannot be independently checked in this container.
- **Change:** Add persisted `memory` boolean with default `false`, `//ac memory on|off`, help/status output, and once-per-target-selection behavior when memory is off. The prior once-per-monster-ID-per-zone behavior remains available with memory on. Rate limit, packet, delay, range gate, and filtering are unchanged.
- **Runtime:** Windower 4 Lua addon. Lua 5.4 shared library is available for local static/mock checks; actual Windower client unavailable.
- **Most recent user-confirmed live behavior:** On 2026-11-09, the user reported v0.1.0 automatic target checks working well, with the native check messages unobtrusive even at `//ac delay 0`. This is not confirmation of the new memory option.
- **Verification:** Lua 5.4 parsing PASSED. v0.1.1 simulated Windower suite PASSED, covering default OFF, one-check-per-continuous-selection, reacquisition checks, delay=0, throttle, memory ON history, switching modes without an immediate duplicate, zone clearing, preserved monster filtering, command validation, status output, packet fields, and saved/reloaded settings. This is not a LuaJIT/FFXI test.
- **Remaining:** In-game memory on/off and reload persistence; packet responses after reacquiring the same monster; timing with real frame events and other addons. No new packet behavior introduced.
- **Next:** Replace installed addon, `//lua r AutoCheck`, confirm `//ac status` shows `memory=OFF`, target A -> B -> A to see a second check of A, then use `//ac memory on` and repeat to confirm the check of A is suppressed.

## v0.1.1 live acceptance tests (not yet run)

1. Upgrade from v0.1.0 and reload; confirm saved delay/interval/on-off settings remain, and `//ac status` reports `memory=OFF` by default.
2. With `//ac memory off`, target A long enough to check, switch away, then reselect A. Confirm one new check of A, without repeated checks while holding A.
3. Repeat at `//ac delay 0` and verify no frame-by-frame check spam; the one-second minimum interval still applies.
4. Run `//ac memory on`. Target A, B, A. Confirm the second targeting of A does not check again within that zone; `//ac reset` or a zone change restores eligibility.
5. Turn memory off while holding a previously checked monster; verify no immediate duplicate until a new selection. Confirm the mode persists after `//lua r AutoCheck`.
6. Retest target filtering, 50-yalm range, and rapid target scrolling only if unexpected behavior appears; their code paths were not otherwise changed.

## v0.1.1 automated checks — 2026-11-09

- **PASS, static parse:** `AutoCheck.lua` parsed with `luaL_loadfilex` via local `liblua5.4.so.0` (not Lua 5.1/LuaJIT).
- **PASS, simulated smoke/regression:** A mocked Windower event/packet/config environment ran the actual Lua addon through 11 injected-check events, verifying the behaviors listed above. Mock runner and test script are tracked under `tests/` in the source repository, excluded from the installable ZIP.
- **NOT RUN:** Windower/FFXI live execution of v0.1.1, true server message responses, or multibox testing.

## v0.1.1 delivery entry — 2026-11-09

- **Contents:** `AutoCheck.lua`, `README.md`, `WORKFLOW.md`, `TESTING.md`, `LICENSE` in the installable `AutoCheck/` folder.
- **Source baseline:** v0.1.0 user-tested ZIP; local reconstructed starting commit `959139d`.
- **Changes:** One feature + docs + simulation, committed on `dev/memory-toggle`. Final local commit is provided in the handoff; no remote publication.
- **Install precautions:** Replace the folder contents and reload. Keep existing Windower-generated per-character settings in `data/` if present; no settings reset is needed.

## v0.1.0 post-delivery live observation — 2026-11-09

- **User-confirmed:** AutoCheck works well in FFXI. Native check messages are not intrusive, even using delay `0`.
- **Requested refinement:** Memory `on|off`, defaulting off; once-per-target-selection while memory is off.
- **Scope:** This confirms the previous v0.1.0 baseline only. v0.1.1 still awaits live testing.

---

## Previous Development Status — 2026-11-09 (v0.1.0 historical snapshot)

The original prototype delivery predated the user’s 2026-11-09 in-game confirmation. Its status below is preserved as originally recorded rather than retroactively describing the current version.

- **Repository / branch:** New local working repository / `dev/target-only-prototype` (no remote configured).
- **Source baseline:** Standalone prototype based on DSGarrett/ImpossibleGauge `main`, inspected 2026-11-09; no upstream files were modified.
- **Runtime:** Windower 4 Lua addon; external client/version not available in this environment.
- **Last user-confirmed live behavior:** None for AutoCheck.
- **Verification:** Lua 5.4 syntax parsing PASSED; simulated Lua mock suite PASSED (target stabilization, cancellation, packet fields, 1s throttle, one-per-ID, reset, zone change, NPC/dead filtering, range gate, on/off, persistence commands, and lifecycle commands). This is not a Windower LuaJIT / FFXI live test.
- **Remaining:** Live validation of packet reception, timing under Windower's clock, target transitions, native result messages, and respawn ID reuse.
- **Next:** Test on one character before simultaneous multibox use.

## Original v0.1.0 live test plan (historical)

1. Load `//lua load AutoCheck`, then `//ac status` and `//ac help`. Confirm no HUD or unwanted chat spam.
2. Quickly cycle Goblin A -> Goblin B -> Goblin C, spending less than 350 ms on A/B. Only C should produce a check result.
3. Hold a single alive monster target for 350 ms. Confirm exactly one normal FFXI check response.
4. Retarget the same monster repeatedly. Confirm no repeated checks until `//ac reset` or zone change.
5. Target two different monsters quickly; verify packets are separated by at least 1 second.
6. Target non-monster NPCs, players, and dead monsters. Confirm no checks.
7. Target a monster >50 yalms away, then approach without retargeting; check should occur only after approaching.
8. Change zones and log out/in. Confirm histories reset.
9. Try `//ac delay 0`, `//ac delay 1000`, `//ac interval 2`, `//ac off`, and `//ac on`; confirm persistence on reload.
10. Respawn an already checked monster in the same zone. Observe whether its entity ID is reused. If so, use `//ac reset` in this version.

## Original v0.1.0 automated checks and results — 2026-11-09

- **PASS, static parse:** AutoCheck/AutoCheck.lua parsed under local Lua 5.4 using liblua's `luaL_loadfilex`. Native Windower Lua 5.1/LuaJIT syntax checking unavailable here.
- **PASS, simulated:** Local mock test (`test_mock.lua` + `run_lua.py`) executed the addon with fake target snapshots, time progression, packet library and command callbacks. Validated check packet `0x0DD` fields, canceled transitions, no duplicate checks, cooldown, zone/history reset, nonmonsters/dead, range hold/approach and commands.
- **NOT RUN:** Actual FFXI client load, Windower native packet library, live check responses, real-world clock timing or multibox behavior.

## Previous checks / results

- None before this initial prototype.

## Delivery register

- 2026-11-09 — v0.1.0 initial local source/test package. Local development branch prototype with automated mock tests; no remote publication and no live FFXI test. See final handoff for the local commit identifier.

## User observations and requests

- 2026-11-09 — Request: automatically check newly targeted monsters with a short, adjustable delay to allow target scrolling.
- 2026-11-09 — Request: start from ImpossibleGauge but restrict all checks to the current target.
