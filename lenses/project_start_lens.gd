class_name ProjectStartLens
extends Lens

const CONTEXT_KEY = "project_start"

var _medium: ConsoleMedium = null
var _channel: ConsoleChannel = null

func set_medium(medium: ConsoleMedium) -> void:
	_medium = medium

func set_channel(channel: ConsoleChannel) -> void:
	_channel = channel

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): project start lens offline.")

func geist_resume() -> void:
	_request_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	var action = text.strip_edges().to_lower()
	match action:
		"c": Scope.transition("profile_creation")
		"s": Scope.transition("profile_selection")
		"t": pass # tealwyv nav, deferred

func _request_compose() -> void:
	if Guard.is_unresolved(_medium, name + ":_request_compose"): return
	var active_name = Profile.get_active_profile().get("name", "none")
	_medium.compose("project_start_main", {"active_name": active_name})
