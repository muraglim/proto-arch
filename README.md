# proto-arch

A modular sandbox architecture for housing and interconnecting game prototypes, built in Godot 4 / GDScript. Text-only phase is an intentional scope constraint for learning.

## Concept

Proto-Arch is a design research platform. Individual prototypes live as self-contained modules within a shared architecture, interoperating through a central state facade and a signal-based navigation system.

Long-term goal: a carousel of game contexts where characters and progression cross game boundaries meaningfully.

## Architecture

**MVC quartet**, all orchestrated declaratively (no `_ready()`, no scene-tree-dependent wiring):

- **Daemon** — model. Logic and state mutation.
- **Channel** — view. Display and raw input, no routing logic of its own.
- **Lens** — controller, input side. Turns raw Channel input into actions/transitions.
- **Medium** — controller, output side. Formats state for display, pushes to a Channel.

State flow is unidirectional: input → Lens → Daemon → Medium → Channel display. 
Control signals (completion, readiness, raw input) can travel between any wired components, only transformed state is one-directional.

**Orchestration:**
- `Main` — bootstrapper, instantiated once as the root scene (not an autoload).
- `Linker` — dependency injection and signal wiring, driven by Ledger-declared dep lists.
- `Scope` — focus manager; gates which Lens receives input via `active_context`.

**Facades:**
- `Keeper` — mutable state, mediates child `Store` nodes.
- `Firm` — immutable data/config, mediates child `Ledger` nodes.
- `Guard` — validation (sentinel pattern).
- `Echo` — debug/print, thin.

Exact method signatures and lifecycle hooks are not documented here.

## Naming & Folders

| Context | Convention | Example |
|---|---|---|
| Base classes | PascalCase | `Channel`, `Daemon`, `Store`, `Ledger` |
| Autoloads | Single-word PascalCase | `Linker`, `Scope`, `Keeper`, `Firm` |
| Store nodes (scene) | `lowercase_prefix_Store` | `profile_Store` |
| Keeper callsite keys | `.to_lower()` of node name | `"profile_store"` |
| Ledger nodes (scene) | `lowercase_prefix_Ledger` | `tealwyv_combat_Ledger` |
| Firm callsite keys | `.to_lower()` of node name | `"tealwyv_combat_ledger"` |
| Scripts (subclasses) | `lower_with_underscore`, min two words | `console_channel`, `profile_daemon` |
| Methods | `lower_case()` everywhere | `channel_init()`, `get_value()` |

```
/core/       — base classes, autoloads
/stores/     — Store subclass instances
/ledgers/    — Ledger subclass instances
/channels/   — Channel subclass scenes and scripts
/daemons/    — Daemon subclass scripts
/lenses/     — Lens subclass scripts
/mediums/    — Medium subclass scripts
```

This README is deliberately thin. Expanded `/docs/` is deferred until the current paradigm has absorbed some dev friction.