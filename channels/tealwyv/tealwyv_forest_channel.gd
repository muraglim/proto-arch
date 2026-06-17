class_name TealwyvForestChannel
extends Channel

enum ForestState {
	HUB,
	COMBAT,
	RESOLUTION
}

var state: ForestState = ForestState.HUB

var _text_daemon: TealwyvTextDaemon = null
var _combat_daemon: TealwyvCombatDaemon = null
var _event_roll_daemon: TealwyvEventRollDaemon = null

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	Linker.register(self)
	input.text_changed.connect(_on_input_changed)

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.max_length = 1
	input.grab_focus()
	_update_hub()

func _on_input_changed(text: String) -> void:
	input.text = ""
	var action = text.strip_edges().to_lower()
	match state:
		ForestState.HUB:
			_handle_hub_input(action)
		ForestState.COMBAT:
			_handle_combat_input(action)
		ForestState.RESOLUTION:
			_handle_resolution_input(action)

func _handle_hub_input(action: String) -> void:
	match action:
		"f":
			_start_combat_encounter()
		"t":
			Nav.to_swap(self, get_nav("tealwyv_town_channel"), SwapAction.EXIT)
		"s":
			Nav.to_swap_return(self, get_nav("tealwyv_player_stats_channel"), SwapAction.SWAP, get_nav("tealwyv_forest_channel"))

func _handle_combat_input(action: String) -> void:
	if _combat_daemon == null:
		push_error("[tealwyv_forest_channel] _handle_combat_input(): no combat daemon.")
		return
	_combat_daemon.take_action(action)

func _handle_resolution_input(action: String) -> void:
	match action:
		"f":
			_start_combat_encounter()
		"r", "c":
			state = ForestState.HUB
			_update_hub()

func _on_combat_event(event: Dictionary) -> void:
	output.text = event.get("text", "")
	if event.get("state") == TealwyvCombatDaemon.EncounterState.RESOLUTION:
		state = ForestState.RESOLUTION

func _start_combat_encounter() -> void:
# event_roll and combat are not cross-wired - combat never calls back into
# event_roll mid-encounter. channel mediates a one-shot handoff: roll here,
# pass result into start_encounter().
	if _combat_daemon == null or _event_roll_daemon == null:
		push_error("[tealwyv_forest_channel] _start_combat_encounter(): missing combat or event roll daemon.")
		return
	state = ForestState.COMBAT
	var enemy: Dictionary = _event_roll_daemon.roll_event()
	_combat_daemon.start_encounter(enemy)

func _update_hub() -> void:
	var flavor = ""
	if _text_daemon != null:
		flavor = _text_daemon.get_prompt("forest_hub_flavor")
	output.text = "%s\n\n[F]ight / [T]own / [S]tats" % flavor

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)
