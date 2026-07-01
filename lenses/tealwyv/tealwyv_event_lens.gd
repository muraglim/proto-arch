class_name TealwyvEventLens
extends Lens

const CONTEXT_KEY = "tealwyv_event"

enum TealwyvEventState {
	IDLE,
	ENCOUNTER,
	RESOLUTION,
}

var state: TealwyvEventState = TealwyvEventState.IDLE

var _medium: ConsoleMedium = null
var _combat_daemon: TealwyvCombatDaemon = null

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): event lens offline.")

func geist_resume(hint: Variant = "") -> void:
	if hint is Dictionary:
		state = TealwyvEventState.ENCOUNTER
		_combat_daemon.start_encounter(hint)
	else:
		_push_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		TealwyvEventState.IDLE:
			pass
		TealwyvEventState.ENCOUNTER:
			_combat_daemon.take_action(text.strip_edges().to_lower())
		TealwyvEventState.RESOLUTION:
			state = TealwyvEventState.IDLE
			Scope.transition("tealwyv_hub")

func _on_combat_event(payload: Dictionary) -> void:
	if Guard.is_null_or_empty(_medium, name + ":_on_combat_event"): return
	_medium.display_raw(payload["text"])
	if payload.has("state"):
		state = TealwyvEventState.RESOLUTION

func _push_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_push_compose"): return
	_medium.compose("tealwyv_event_main", {})
