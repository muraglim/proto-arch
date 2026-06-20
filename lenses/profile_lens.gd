class_name ProfileLens
extends Lens

const CONTEXT_KEY = "profile"

enum ProfileState {
	CREATION_PROMPT,
	CREATION_SUBMIT,
	CREATION_ERROR,
	SELECTION
}

var state: ProfileState = ProfileState.CREATION_PROMPT
var _error_key: String = ""

var _medium: ConsoleMedium = null
var _daemon: ProfileDaemon = null

func set_medium(medium: ConsoleMedium) -> void:
	_medium = medium

func set_daemon(daemon: ProfileDaemon) -> void:
	_daemon = daemon

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): profile lens offline.")

func geist_resume(hint: String = "") -> void:
	match hint:
		"creation": state = ProfileState.CREATION_PROMPT
		"selection": state = ProfileState.SELECTION
	_request_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		ProfileState.CREATION_PROMPT, ProfileState.CREATION_ERROR:
			_handle_creation_prompt(text)
		ProfileState.CREATION_SUBMIT: pass
		ProfileState.SELECTION: _handle_selection(text)

func _handle_creation_prompt(text: String) -> void:
	var profile_name = text.strip_edges()
	state = ProfileState.CREATION_SUBMIT
	_daemon.submit_creation(profile_name)

func _handle_creation_error() -> void:
	state = ProfileState.CREATION_PROMPT
	_error_key = ""
	_request_compose()

func _handle_selection(text: String) -> void:
	_daemon.submit_selection(text.strip_edges().to_lower())

func _on_creation_failed(error_key: String) -> void:
	_error_key = error_key
	state = ProfileState.CREATION_ERROR
	_request_compose()

func _on_creation_succeeded() -> void:
	Scope.transition("project_start")

func _on_selection_succeeded() -> void:
	Scope.transition("project_start")

func _request_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_request_compose"): return
	var max_len = Firm.get_value("profile_ledger", "max_name_length")
	match state:
		ProfileState.CREATION_PROMPT:
			_medium.set_input_constraint(max_len)
			_medium.compose("profile_creation_prompt", {"max_len": max_len})
		ProfileState.CREATION_ERROR:
			_medium.compose(_error_key, _get_error_data(_error_key))
		ProfileState.SELECTION:
			_medium.set_input_constraint(max_len)
			_medium.compose("profile_selection_prompt", {"profiles": _get_profile_list()})

func _get_error_data(error_key: String) -> Dictionary:
	match error_key:
		"profile_creation_forbidden":
			return {"chars": " ".join(Firm.get_value("profile_ledger", "forbidden_chars"))}
		_:
			return {}

func _get_profile_list() -> String:
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	var lines: Array = []
	for profile in profiles:
		lines.append(profile["name"])
	return "\n".join(lines)
