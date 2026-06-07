extends Channel



enum ForestState {
	HUB,
	COMBAT,
	RESOLUTION
}

var state: ForestState = ForestState.HUB
var combat_daemon: Daemon = null
var text_daemon = null
# TODO: not used in current scope of script, may be necessary when extending features involving multi-character input
# affects is_input_constrained, input.max_length, and strip_edges() - forward looking guards/toggles
var is_input_constrained: bool = true
var constrained_inputs: Array[String] = []

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func wire_to_daemon(daemon: Daemon) -> void:
	if daemon.has_signal("combat_update"):
		combat_daemon = daemon
		combat_daemon.combat_update.connect(_on_combat_update)
		state = ForestState.COMBAT
		return
	if daemon.has_method("get_prompt"):
		text_daemon = daemon

func channel_init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	RenderingServer.set_default_clear_color(Color.BLACK)
	input.max_length=1
	input.text_changed.connect(_on_input_changed)
	if not _is_luck_daemon_running():
		Nav.to_daemon(self, get_nav("tealwyv_luck_daemon"))
	if not _is_text_daemon_running():
		Nav.to_daemon(self, get_nav("tealwyv_text_daemon"))
	update_menu()

func update_menu() -> void:
	match state:
		ForestState.HUB:
			constrained_inputs = ["f", "t", "h"]
			var flavor = ""
			if text_daemon != null:
				flavor = text_daemon.get_prompt("hub_flavor")
			output.text = "%s\n\n[F]ight / [T]own / [H]eal" % flavor
		ForestState.COMBAT:
			pass # driven by combat_update signal
		ForestState.RESOLUTION:
			pass # driven by combat_update signal

func _on_input_changed(text: String) -> void:
	input.text = ""
	var action = text.strip_edges().to_lower()
	if is_input_constrained and not constrained_inputs.has(action):
		return
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
			RenderingServer.set_default_clear_color(Color.DARK_BLUE)
			constrained_inputs = ["a", "r", "c"]
			Nav.to_daemon(self, get_nav("tealwyv_combat_daemon"))
		"t":
			output.text = "You wander in the direction of the town [F]ight]"
		"h":
			var hp_max = Keeper.get_value("tealwyv_player_store", "hp_max")
			Keeper.set_value("tealwyv_player_store", "hp", hp_max)
			output.text = "[DEV] HP restored to %d. [fight/town]" % hp_max
		_:
			output.text = "Unknown command. [fight / town]"

func _handle_combat_input(action: String) -> void:
	if combat_daemon == null:
		push_error("[tealwyv_forest_channel] _handle_combat_input(): no combat daemon reference.")
		return
	combat_daemon.call("take_action", action)

func _handle_resolution_input(action: String) -> void:
	match action:
		"f":
			state = ForestState.COMBAT
			Nav.to_daemon(self, get_nav("tealwyv_combat_daemon"))
		"r":
			state = ForestState.HUB
			Nav.evict_daemon(self, get_nav("tealwyv_combat_daemon"))
			update_menu()
		"c":
			state = ForestState.HUB
			Nav.evict_daemon(self, get_nav("tealwyv_combat_daemon"))
			update_menu()
		_:
			output.text = "Unknown command."

func _on_combat_update(text: String) -> void:
	output.text = text
	if not combat_daemon.is_combat_active:
		state = ForestState.RESOLUTION

func _is_luck_daemon_running() -> bool:
	if _main == null: return false
	return _main.is_in_under(get_nav("tealwyv_luck_daemon"))

func _is_text_daemon_running() -> bool:
	if _main == null: return false
	return _main.is_in_under(get_nav("tealwyv_text_daemon"))

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)

@warning_ignore("unused_signal")
signal combat_action(action: String)
