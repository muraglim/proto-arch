# proto-arch

A modular sandbox architecture for housing and interconnecting game prototypes, built in Godot 4 using GDScript. Text-only phase is an intentional scope constraint for learning.

## Concept

Proto-Arch is a design research platform. Individual prototypes live as self-contained modules within a shared architecture, interoperating through a central state facade and a signal-based navigation system.

Long-term design goal: a carousel of game contexts where characters and progression cross game context boundaries meaningfully. This is future intent, not current scope.

## Architecture

### Scene Structure

Main (`main.gd`) is the scene manager and bootstrapper. It is not an autoload — instantiated once as the root scene. It owns three containers:

- `front` — active Channel, primary input and display
- `back` — cached Channels, swapped out but not destroyed
- `under` — active Daemons, logic layer only

### Autoloads

**Nav** — navigation facade. All navigation calls route through Nav methods. Guard checks and signal emission are centralized here. Signals live on the calling instance — Nav drives them, does not own them.

**Keeper** — state facade. Manages child Store nodes registered at ready via the scene tree. Callsites never interact with stores directly — all reads and writes go through Keeper's proxied methods. Child store nodes use a `lowercase_prefix_Store` naming convention; Keeper keys are derived via `.to_lower()`.

**Firm** — immutable state facade. Manages child Ledger nodes registered at ready via the scene tree. Read-only by design — no mutation methods. Structurally separate from Keeper; Ledger nodes live in Firm's scene tree, not Keeper's. Child ledger nodes use a `lowercase_prefix_Ledger` naming convention; Firm keys are derived via `.to_lower()`.

**Guard** — validation layer. Provides guard checks used at callsites across the codebase. Returns `true` on error condition (stop/early return pattern).

### Base Classes

**Channel** (`channel.gd`) extends Control — display and input handling. Lives in `front` or `back`. Lifecycle methods: `channel_init()`, `channel_shutdown()`, `channel_pause()`, `channel_resume()`, `channel_hide()`, `channel_unhide()`, `channel_show()`. Do not use `_ready()` in subclasses — use `channel_init()`, which fires after scene tree insertion and bootstrapper wiring.

**Daemon** (`daemon.gd`) extends Node — logic only, no scene. Lives in `under`. Script-only by design; never attach a scene. Lifecycle methods: `daemon_init()`, `daemon_shutdown()`, `daemon_pause()`, `daemon_resume()`. Do not use `_ready()` in subclasses — use `daemon_init()`.

**Ledger** (`ledger.gd`) extends Node — base class for all constant data records. Child of Firm in the scene tree. Data is authored inline in subclass `_ready()` and never mutated at runtime. Retrieval is mediated through Firm — do not access Ledger subclasses directly.

**Store** (`store.gd`) extends Node — base class for all mutable state stores. Child of Keeper in the scene tree. Subclasses:
- `PersistentStore` — adds file-backed persistence. Loads on ready, merges over defaults (unknown keys from file are ignored to protect against stale save data).
- `AutoSaveStore` — extends PersistentStore, saves on every `set_value()` mutation.

### Navigation

All navigation routes through Nav. Channels and Daemons emit signals; Nav drives emission, Main handles the signal callbacks and executes routing logic. Nav methods validate callers have the required signal before emitting.

SwapAction enum (defined on Channel) controls routing behavior:
- `EXIT` — current Channel is shut down and freed before the new one starts
- `SWAP` — current Channel is paused and moved to `back`, available for resume

### Channel/Daemon Wiring

A Channel's daemon dependencies are declared in `_channel_dep_Ledger` as an ordered array keyed by channel name. Each entry specifies a `dest` (nav key into `_nav_dest_Ledger`) and a `role`. On `channel_init()`, the channel's `_boot_daemons()` reads its dependency list from Firm and calls `Nav.to_daemon()` for each entry in order. Main instantiates each daemon and calls `channel.wire_to_daemon(daemon)`, which dispatches to `daemon.wire_to_channel(channel)`. Daemons self-register against the channel by calling the appropriate typed registration method (e.g. `register_luck_daemon()`, `register_combat_daemon()`).

Daemon-to-daemon dependencies (e.g. combat daemon requiring a luck daemon reference) are mediated by the channel: the channel passes the reference through when both sides are registered. The channel owns the introduction - daemons do not reach across to each other directly.

This pattern is the settled template for all future Channel/Daemon relationships in the project.

### Tooling Layer

**_pComb** — lightweight print/logging helpers for in-development interrogation. Not a debug system — a quick reach for when you need to look at something.

**_dGnostic** — deferred until gameplay complexity warrants more systematic inspection than print calls provide.

Tooling autoloads use a `lowercase_prefix + PascalCase` naming convention (`_pComb`, `_dGnostic`). The lowercase prefix describes the function category. New tooling slots into this system by assigning a prefix.

## Naming Conventions

| Context | Convention | Example |
|---|---|---|
| Base classes | PascalCase | `Channel`, `Daemon`, `Store`, `Ledger` |
| Autoloads | Single-word PascalCase | `Nav`, `Keeper`, `Guard`, `Firm` |
| Tooling autoloads | `_lowercasePrefix + PascalCase` | `_pComb`, `_dGnostic` |
| Store child nodes (scene) | `lowercase_prefix_Store` | `nav_dest_Store` |
| Keeper callsite keys | `.to_lower()` of node name | `"_nav_dest_store"` |
| Ledger child nodes (scene) | `lowercase_prefix_Ledger` | `tealwyv_forest_Ledger` |
| Firm callsite keys | `.to_lower()` of node name | `"tealwyv_forest_ledger"` |
| Scene scripts (subclasses) | `lower_with_underscore`, min two words | `nav_checker`, `nav_check_daemon` |
| Methods | `lower_case()` everywhere | `channel_init()`, `get_value()` |

## Folder Structure

```
/core/       — base classes, autoloads
/stores/     — Store subclass instances
/ledgers/    — Ledger subclass instances
/channels/   — Channel subclass scenes and scripts
/daemons/    — Daemon subclass scripts
```

## Dismiss vs Evict

Semantic distinction used throughout the codebase for lifecycle termination calls:

- **dismiss** — a container exiting itself, or a sibling triggering a sibling exit (Channel dismissing Channel, Daemon dismissing Daemon)
- **evict** — cross-type boundary termination (Daemon triggering Channel exit, Channel triggering Daemon exit)

## Tooling Intent

The codebase trends toward self-documenting and machine-readable. As Python literacy develops naturally from GDScript familiarity, the intent is to build lightweight automation tooling that surfaces accumulated debt and process signals — TODO pullup across the file tree, nav path verification, callsite hygiene checks before commits. Implementation deferred until there is sufficient codebase familiarity to design against real friction rather than speculated friction.

## Status

Early development. Architecture is stable. Channel/Daemon wiring pattern is settled and live — dependency declaration via `_channel_dep_Ledger`, self-registration via `wire_to_channel()`, and channel-mediated daemon introductions are the established template. Single text-based prototype environment in progress.
