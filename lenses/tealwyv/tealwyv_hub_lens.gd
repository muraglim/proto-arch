class_name TealwyvHubLens
extends Lens

const CONTEXT_KEY = "tealwyv_hub"

var _medium: ConsoleMedium = null

func set_medium(medium: ConsoleMedium) -> void:
	_medium = medium

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): hub lens offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: String = "") -> void:
	_request_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	var action = text.strip_edges().to_lower()
	match action:
		"b":
			Mount.unmount(self)
			Scope.transition("tealwyv_start")

func _request_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_request_compose"): return
	_medium.compose("tealwyv_hub_main", {})
