class_name TealwyvHubLens
extends Lens

const CONTEXT_KEY = "tealwyv_hub"

var _medium: ConsoleMedium = null
var _event_roll_daemon: TealwyvEventRollDaemon = null
var _text_daemon: TealwyvTextDaemon = null

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): hub lens offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	_push_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	var action = text.strip_edges().to_lower()
	match action:
		"f":
			if Guard.is_null_or_empty(_event_roll_daemon, name + ":_on_input.forest"): return
			var enemy = _event_roll_daemon.roll_event()
			Scope.focus.call_deferred("tealwyv_event", enemy)
		"b":
			Mount.unmount(self)
			Scope.focus("tealwyv_start")

func _push_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_push_compose"): return
	if Guard.is_null_or_empty(_text_daemon, name + ":_push_compose"): return
	_medium.compose("tealwyv_hub_main", {"flavor": _text_daemon.get_prompt("forest_hub_flavor")})
