class_name PaleolithPocketLens
extends Lens

const CONTEXT_KEY = "paleolith_pocket"

var _medium: PaleolithMedium = null

func set_medium(medium: PaleolithMedium) -> void:
	_medium = medium

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	_request_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match text.strip_edges().to_lower():
		"b":
			Mount.unmount(self)
			Scope.transition("paleolith_hub")

func _request_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_request_compose"): return
	_medium.compose("paleolith_pocket_stub", {})