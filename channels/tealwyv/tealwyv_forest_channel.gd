class_name TealwyvForestChannel
extends Channel

enum ForestState {
	HUB,
	COMBAT,
	RESOLUTION
}

var state: ForestState = ForestState.HUB

var _luck_daemon: TealwyvLuckDaemon = null
var _text_daemon: TealwyvTextDaemon = null
var _combat_daemon: TealwyvCombatDaemon = null
var _event_roll_daemon: TealwyvEventRollDaemon = null
var _reward_daemon: TealwyvRewardDaemon = null

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	_boot_daemons()
	input.text_changed.connect(_on_input_changed)

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.max_length = 1
	input.grab_focus()
	_update_hub()

func _boot_daemons() -> void:
	var deps: Array = Firm.get_value("_channel_dep_ledger", "tealwyv_forest_channel")
	for dep in deps:
		Nav.to_daemon(self, get_nav(dep["dest"]))

func wire_to_daemon(daemon: Daemon) -> void:
	daemon.wire_to_channel(self)

# called by channel.gd base via wire_to_daemon — daemons self-register by role
func register_luck_daemon(daemon: TealwyvLuckDaemon) -> void:
	_luck_daemon = daemon
	if _combat_daemon != null:
		_combat_daemon.wire_to_luck_daemon(_luck_daemon)

func register_text_daemon(daemon: TealwyvTextDaemon) -> void:
	_text_daemon = daemon

func register_event_roll_daemon(daemon: TealwyvEventRollDaemon) -> void:
	_event_roll_daemon = daemon

func register_combat_daemon(daemon: TealwyvCombatDaemon) -> void:
	_combat_daemon = daemon
	_combat_daemon.combat_event.connect(_on_combat_event)
	if _luck_daemon != null:
		_combat_daemon.wire_to_luck_daemon(_luck_daemon)
	if _reward_daemon != null:
		_combat_daemon.wire_to_reward_daemon(_reward_daemon)	

func register_reward_daemon(daemon: TealwyvRewardDaemon) -> void:
	_reward_daemon = daemon
	if _combat_daemon != null:
		_combat_daemon.wire_to_reward_daemon(_reward_daemon)

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
			Nav.to_swap(self, get_nav("tealwyv_town_channel"), SwapAction.SWAP)
		"h":
			var hp_max = Keeper.get_value("tealwyv_player_store", "hp_max")
			Keeper.set_value("tealwyv_player_store", "hp", hp_max)
			output.text = "[DEV] HP restored to %d.\n\n[F]ight / [T]own / [H]eal" % hp_max

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
# event_roll_daemon and combat_daemon are not cross-wired - unlike luck/reward,
# combat never calls back into event_roll mid-encounter. the channel mediates
# a one-shot handoff: roll here, pass the result into start_encounter().
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
	output.text = "%s\n\n[F]ight / [T]own / [H]eal" % flavor

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)
