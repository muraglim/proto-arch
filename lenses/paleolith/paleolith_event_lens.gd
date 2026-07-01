class_name PaleolithEventLens
extends Lens

const CONTEXT_KEY = "paleolith_event"

# — state —

enum EventState { TRAVEL, EVENT_PROMPT, DRINK_CHOICE, EVENT_RESOLUTION }

var state: EventState = EventState.TRAVEL
var _hint: Dictionary = {}
var _current_event: Dictionary = {}
var _pursuit_fired: bool = false
var _player_choice: String = ""

# — deps —

var _medium: PaleolithMedium = null
var _event_roll_daemon: PaleolithEventRollDaemon = null
var _outcome_roll_daemon: PaleolithOutcomeRollDaemon = null

# — lifecycle —

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

func geist_resume(hint: Variant = "") -> void:
	if not hint is Dictionary or (hint as Dictionary).is_empty():
		push_error(name + ":geist_resume — hint must be a non-empty Dictionary")
		return
	_hint = hint
	_current_event = {}
	_pursuit_fired = false
	_player_choice = ""
	state = EventState.TRAVEL
	_roll_and_compose()

# — roll —

func _roll_and_compose() -> void:
	if Guard.is_null_or_empty(_event_roll_daemon, name + ":_roll_and_compose"): return
	if Guard.is_null_or_empty(_medium, name + ":_roll_and_compose"): return
	var context: String = _hint.get("context", "travel")
	var location: String = _hint.get("location", "")
	_current_event = _event_roll_daemon.roll_for_event(context, location)
	if _current_event.is_empty():
		_medium.compose("paleolith_event_travel", {"location": location, "context": context})
		return
	state = EventState.EVENT_PROMPT
	_medium.compose("paleolith_event_nest_prompt", {
		"location": location,
		"yield_min": _current_event.get("yield_min", 1),
		"yield_max": _current_event.get("yield_max", 3),
	})

# — input —

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	var action := text.strip_edges().to_lower()
	match state:
		EventState.TRAVEL:
			_on_travel_continue()
		EventState.EVENT_PROMPT:
			_on_event_prompt(action)
		EventState.DRINK_CHOICE:
			_on_drink_choice(action)
		EventState.EVENT_RESOLUTION:
			_on_resolution_continue()

func _on_travel_continue() -> void:
	Scope.transition(_hint.get("destination", "paleolith_hub"), _hint.get("location", ""))

func _on_event_prompt(action: String) -> void:
	match action:
		"1":
			_player_choice = "ignore"
			_resolve_event()
		"2":
			_player_choice = "take_one"
			_resolve_event()
		"3":
			_player_choice = "take_two"
			_resolve_event()
		"4":
			_player_choice = "drink_only"
			state = EventState.DRINK_CHOICE
			_medium.compose("paleolith_event_nest_drink_choice", {})

func _on_drink_choice(action: String) -> void:
	match action:
		"y":
			_player_choice = "drink_take_one"
			_resolve_event()
		"n":
			_resolve_event()

func _on_resolution_continue() -> void:
	# stub: always proceed to destination.
	# when health system exists, death routes to _hint["return_context"] instead.
	Scope.transition(_hint.get("destination", "paleolith_hub"), _hint.get("location", ""))

# — resolution —

func _resolve_event() -> void:
	if Guard.is_null_or_empty(_outcome_roll_daemon, name + ":_resolve_event"): return
	_outcome_roll_daemon.apply_outcome(_current_event.get("event_key", ""), _player_choice)
	_pursuit_fired = _roll_pursuit()
	state = EventState.EVENT_RESOLUTION
	_medium.compose("paleolith_event_nest_resolution", {
		"choice": _player_choice,
		"pursuit_fired": _pursuit_fired,
	})

func _roll_pursuit() -> bool:
	match _player_choice:
		"ignore", "drink_only":
			return false
	var base: float = _current_event.get("pursuit_base", 0.3)
	var modifiers: Array = []
	if _player_choice == "take_two":
		modifiers.append(_current_event.get("pursuit_two_eggs_modifier", 0.2))
	elif _player_choice == "drink_take_one":
		modifiers.append(_current_event.get("pursuit_drink_modifier", 0.15))
	return _outcome_roll_daemon.roll_outcome(base, modifiers)
