class_name PerstaltStartLens
extends Lens

const CONTEXT_KEY = "perstalt_start"

enum PerstaltStartState {
	FOYER,
	CREATION_PROMPT,
	CREATION_ERROR,
	SELECTION,
	SELECTION_ERROR,
	DELETION,
	DELETION_CONFIRM,
	DELETION_ERROR,
}

var state: PerstaltStartState = PerstaltStartState.FOYER
var _pending_delete: String = ""
var _error_key: String = ""

var _medium: ConsoleMedium = null
var _daemon: PerstaltWorldDaemon = null

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): perstalt start lens offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	state = PerstaltStartState.FOYER
	_daemon.restore_active_binding()
	_push_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		PerstaltStartState.FOYER:
			_handle_foyer(text)
		PerstaltStartState.CREATION_PROMPT, PerstaltStartState.CREATION_ERROR:
			_handle_creation(text)
		PerstaltStartState.SELECTION, PerstaltStartState.SELECTION_ERROR:
			_handle_selection(text)
		PerstaltStartState.DELETION, PerstaltStartState.DELETION_ERROR:
			_handle_deletion(text)
		PerstaltStartState.DELETION_CONFIRM:
			_handle_deletion_confirm(text)

func _handle_foyer(text: String) -> void:
	var action = text.strip_edges().to_lower()
	match action:
		"c":
			state = PerstaltStartState.CREATION_PROMPT
			_push_compose()
		"s":
			if _get_world_list().is_empty():
				pass # [S] not shown — silently ignore
			else:
				state = PerstaltStartState.SELECTION
				_push_compose()
		"d":
			if _get_world_list().is_empty():
				pass # [D] not shown — silently ignore
			else:
				state = PerstaltStartState.DELETION
				_push_compose()
		"b":
			Scope.focus("project_start")
			Mount.unmount(self)

func _handle_creation(text: String) -> void:
	var world_name = text.strip_edges()
	if world_name.is_empty():
		state = PerstaltStartState.FOYER
		_push_compose()
		return
	_daemon.submit_creation(world_name)

func _handle_selection(text: String) -> void:
	_daemon.submit_selection(text.strip_edges())

func _handle_deletion(text: String) -> void:
	var world_name = text.strip_edges()
	if world_name.is_empty():
		state = PerstaltStartState.FOYER
		_push_compose()
		return
	_pending_delete = world_name
	state = PerstaltStartState.DELETION_CONFIRM
	_push_compose()

func _handle_deletion_confirm(text: String) -> void:
	var action = text.strip_edges().to_lower()
	if action == "y":
		_daemon.submit_deletion(_pending_delete)
		_pending_delete = ""
		return
	_pending_delete = ""
	state = PerstaltStartState.FOYER
	_push_compose()

func _on_creation_failed(error_key: String) -> void:
	_error_key = error_key
	state = PerstaltStartState.CREATION_ERROR
	_push_compose()

func _on_creation_succeeded() -> void:
	state = PerstaltStartState.FOYER
	_push_compose()

func _on_selection_failed(error_key: String) -> void:
	_error_key = error_key
	state = PerstaltStartState.SELECTION_ERROR
	_push_compose()

func _on_selection_succeeded() -> void:
	state = PerstaltStartState.FOYER
	_push_compose()

func _on_deletion_failed(error_key: String) -> void:
	_error_key = error_key
	state = PerstaltStartState.DELETION_ERROR
	_push_compose()

func _on_deletion_succeeded() -> void:
	state = PerstaltStartState.FOYER
	_push_compose()

func _push_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_push_compose"): return
	var max_len = Firm.get_value("perstalt_world_ledger", "max_name_length")
	match state:
		PerstaltStartState.FOYER:
			_medium.set_input_constraint(0)
			var foyer_key = "perstalt_start_main" if not _get_world_list().is_empty() \
				else "perstalt_start_main_no_worlds"
			_medium.compose(foyer_key, {
				"active_profile_name": Profile.get_active_profile().get("name", "none"),
				"active_world_name": _get_active_world_name(),
			})
		PerstaltStartState.CREATION_PROMPT:
			_medium.set_input_constraint(max_len)
			_medium.compose("perstalt_world_creation_prompt", {"max_len": max_len})
		PerstaltStartState.CREATION_ERROR:
			_medium.compose(_error_key, _get_error_data(_error_key))
		PerstaltStartState.SELECTION:
			_medium.compose("perstalt_world_selection_prompt", {"worlds": _get_world_list()})
		PerstaltStartState.SELECTION_ERROR:
			_medium.compose(_error_key, {"worlds": _get_world_list()})
		PerstaltStartState.DELETION:
			_medium.compose("perstalt_world_deletion_prompt", {"worlds": _get_world_list()})
		PerstaltStartState.DELETION_CONFIRM:
			_medium.compose("perstalt_world_deletion_confirm", {"world_name": _pending_delete})
		PerstaltStartState.DELETION_ERROR:
			_medium.compose(_error_key, {"worlds": _get_world_list()})

func _get_error_data(error_key: String) -> Dictionary:
	match error_key:
		"perstalt_world_creation_forbidden":
			return {"chars": " ".join(Firm.get_value("perstalt_world_ledger", "forbidden_chars"))}
		_:
			return {}

func _get_world_list() -> String:
	var worlds = Keeper.get_value("perstalt_world_store", "worlds", [])
	var active_profile_id = Profile.get_active_profile_id()
	var lines: Array = []
	for world in worlds:
		if world.get("profile_id") == active_profile_id:
			lines.append(world["name"])
	return "\n".join(lines)

func _get_active_world_name() -> String:
	var active_world_id = Keeper.get_value("perstalt_world_store", "active_world_id", "")
	if active_world_id.is_empty():
		return "none"
	var worlds = Keeper.get_value("perstalt_world_store", "worlds", [])
	for world in worlds:
		if world["id"] == active_world_id and world.get("profile_id") == Profile.get_active_profile_id():
			return world["name"]
	return "none"
