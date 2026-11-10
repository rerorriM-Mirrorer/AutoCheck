# AutoCheck development workflow

Adapted from NPCMirror's canonical `WORKFLOW.md` on `rerorriM-Mirrorer/ffxi-NPCmirror` (reviewed from GitHub on 2026-11-09). This is a new standalone prototype without an upstream AutoCheck repository. This document is **not** a verbatim copy of NPCMirror's canonical workflow; consult the canonical file before further repo development.

- Aim for an invisible, native-feeling FFXI enhancement; avoid unrelated UI or behavior changes.
- Keep changes small and traceable. Preserve tested behavior and maintain useful help/status output.
- Read current repository `AGENTS.md`, `WORKFLOW.md`, and `TESTING.md` before making future substantial changes.
- Maintain configuration under Windower's config library, not globals.
- Verify Lua syntax, behavior with mocks, and actual FFXI behavior separately; never claim simulated results are live.
- Record observed packet details rather than treating assumptions as confirmed. Packet logic is based on ImpossibleGauge's `0x0DD` implementation; server reception in this prototype is unverified.
- Maintain README and a cumulative TESTING record; deliver workflow and testing notes alongside the addon files.
- Develop on a working branch and report precisely what is local, committed, pushed, and live-verified.
