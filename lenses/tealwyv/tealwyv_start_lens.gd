class_name TealwyvStartLens
extends Lens

const CONTEXT_KEY = "tealwyv_start"

enum TealwyvStartState {
	FOYER,
	CREATION_PROMPT,
	CREATION_GENDER,
	CREATION_SUBMIT,
	CREATION_ERROR,
	SELECTION,
	SELECTION_ERROR,
}

var state: TealwyvStartState = TealwyvStartState.FOYER
var _pending_name: String = ""
var _error_key: String = ""

var _medium: ConsoleMedium = null
var _daemon: TealwyvCharacterDaemon = null

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): tealwyv start lens offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	state = TealwyvStartState.FOYER
	_push_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		TealwyvStartState.FOYER:
			_handle_foyer(text)
		TealwyvStartState.CREATION_PROMPT, TealwyvStartState.CREATION_ERROR:
			_handle_creation_prompt(text)
		TealwyvStartState.CREATION_GENDER:
			_handle_creation_gender(text)
		TealwyvStartState.CREATION_SUBMIT:
			pass
		TealwyvStartState.SELECTION, TealwyvStartState.SELECTION_ERROR:
			_handle_selection(text)

func _handle_foyer(text: String) -> void:
	var action = text.strip_edges().to_lower()
	match action:
		"c":
			state = TealwyvStartState.CREATION_PROMPT
			_push_compose()
		"s":
			if _get_character_list().is_empty():
				pass # [S] not shown — silently ignore
			elif _is_only_character_selected():
				_medium.compose("tealwyv_already_selected", {})
			else:
				state = TealwyvStartState.SELECTION
				_push_compose()
		"t":
			Mount.mount_lens("tealwyv_hub_lens")
			Scope.transition.call_deferred("tealwyv_hub")
		"b":
			Scope.transition("project_start")
			Mount.unmount(self)

func _handle_creation_prompt(text: String) -> void:
	var character_name = text.strip_edges()
	if character_name.is_empty():
		state = TealwyvStartState.FOYER
		_push_compose()
		return
	_pending_name = character_name
	state = TealwyvStartState.CREATION_GENDER
	_push_compose()

func _handle_creation_gender(text: String) -> void:
	var input = text.strip_edges().to_lower()
	if input.is_empty():
		_pending_name = ""
		state = TealwyvStartState.FOYER
		_push_compose()
		return
	var valid_genders: Array = Firm.get_value("tealwyv_character_ledger", "genders")
	if not input in valid_genders:
		_medium.compose("tealwyv_character_creation_gender_invalid", {})
		return
	state = TealwyvStartState.CREATION_SUBMIT
	_daemon.submit_creation(_pending_name, input)

func _handle_selection(text: String) -> void:
	_daemon.submit_selection(text.strip_edges())

func _on_creation_failed(error_key: String) -> void:
	_error_key = error_key
	_pending_name = ""
	state = TealwyvStartState.CREATION_ERROR
	_push_compose()

func _on_creation_succeeded() -> void:
	_pending_name = ""
	state = TealwyvStartState.FOYER
	_push_compose()

func _on_selection_failed(error_key: String) -> void:
	_error_key = error_key
	state = TealwyvStartState.SELECTION_ERROR
	_push_compose()

func _on_selection_succeeded() -> void:
	state = TealwyvStartState.FOYER
	_push_compose()

func _push_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_push_compose"): return
	var max_len = Firm.get_value("tealwyv_character_ledger", "max_name_length")
	match state:
		TealwyvStartState.FOYER:
			var foyer_key = "tealwyv_start_main" if not _get_character_list().is_empty() \
				else "tealwyv_start_main_no_characters"
			_medium.compose(foyer_key, {
				"active_profile_name": Profile.get_active_profile().get("name", "none"),
				"active_character_name": _get_active_character_name(),
			})
		TealwyvStartState.CREATION_PROMPT:
			_medium.set_input_constraint(max_len)
			_medium.compose("tealwyv_character_creation_prompt", {"max_len": max_len})
		TealwyvStartState.CREATION_GENDER:
			_medium.set_input_constraint(0)
			_medium.compose("tealwyv_character_creation_gender_prompt", {})
		TealwyvStartState.CREATION_ERROR:
			_medium.compose(_error_key, _get_error_data(_error_key))
		TealwyvStartState.SELECTION:
			_medium.compose("tealwyv_character_selection_prompt", {"characters": _get_character_list()})
		TealwyvStartState.SELECTION_ERROR:
			_medium.compose(_error_key, {"characters": _get_character_list()})

func _get_error_data(error_key: String) -> Dictionary:
	match error_key:
		"tealwyv_character_creation_forbidden":
			return {"chars": " ".join(Firm.get_value("tealwyv_character_ledger", "forbidden_chars"))}
		_:
			return {}

func _get_character_list() -> String:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_profile_id = Profile.get_active_profile_id()
	var lines: Array = []
	for character in characters:
		if character.get("profile_id") == active_profile_id:
			lines.append(character["name"])
	return "\n".join(lines)

func _get_active_character_name() -> String:
	var active_character_id = Keeper.get_value("tealwyv_character_store", "active_character_id")
	if active_character_id == null or active_character_id.is_empty():
		return "none"
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	for character in characters:
		if character["id"] == active_character_id and character.get("profile_id") == Profile.get_active_profile_id():
			return character["name"]
	return "none"

func _is_only_character_selected() -> bool:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_profile_id = Profile.get_active_profile_id()
	var profile_chars = characters.filter(func(c): return c.get("profile_id") == active_profile_id)
	if profile_chars.size() != 1: return false
	var active_id = Keeper.get_value("tealwyv_character_store", "active_character_id", "")
	return profile_chars[0]["id"] == active_id
