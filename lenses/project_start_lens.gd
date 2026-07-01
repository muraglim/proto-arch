class_name ProjectStartLens
extends Lens

const CONTEXT_KEY = "project_start"

var _medium: ConsoleMedium = null

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): project start lens offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	_push_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	var action = text.strip_edges().to_lower()
	match action:
		"c":
			Mount.mount_lens("profile_lens")
			Scope.focus.call_deferred("profile", "creation")
		"s":
			Mount.mount_lens("profile_lens")
			Scope.focus.call_deferred("profile", "selection")
		"t":
			Mount.mount_lens("tealwyv_start_lens")
			Scope.focus.call_deferred("tealwyv_start")
		"p":
			Mount.mount_lens("paleolith_hub_lens")
			Scope.focus.call_deferred("paleolith_hub")

func _push_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_push_compose"): return
	var active_name = Profile.get_active_profile().get("name", "none")
	_medium.compose("project_start_main", {"active_name": active_name})
