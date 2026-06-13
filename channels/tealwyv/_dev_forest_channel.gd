class_name DevForestChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var input: LineEdit = $MarginContainer/VBoxContainer/RichTextLabel/LineEdit

func channel_init() -> void:
	input.placeholder_text = "command..."
	input.gui_input.connect(_on_gui_input)
	_draw_menu()
	Nav.to_back_start(self, get_nav("tealwyv_forest_channel"))

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _draw_menu() -> void:
	var attack = Keeper.get_value("tealwyv_player_store", "attack")
	var defense = Keeper.get_value("tealwyv_player_store", "defense")
	var hp_max = Keeper.get_value("tealwyv_player_store", "hp_max")
	var enemy_level = Keeper.get_value("_dev_store", "enemy_level")
	var level_display = str(enemy_level) if enemy_level > 0 else "unset (defaults to 1)"
	output.text = "[DEV] tealwyv_forest\n\natk: %d | def: %d | hp_max: %d\nenemy level: %s\n\natk <n> | def <n> | hp <n> | level <n> | reset | exit" % [attack, defense, hp_max, level_display]
	
func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed or event.keycode != KEY_ENTER: return
	var raw = input.text.strip_edges().to_lower()
	input.text = ""
	if raw.is_empty(): return
	var parts = raw.split(" ", false)
	var cmd = parts[0]
	match cmd:
		"exit":
			output.text = ""
			Nav.to_swap(self, get_nav("tealwyv_forest_channel"), Channel.SwapAction.SWAP)
			return
		"reset":
			Keeper.set_value("_dev_store", "enemy_level", 0)
			_draw_menu()
			return
	if parts.size() > 2:
		output.text = "unknown command. atk <n> | def <n> | hp <n> | level <n> | reset | exit"
		return
	var val = parts[1].to_int()
	if val <= 0:
		output.text = "value must be a positive integer"
		return
	match cmd:
		"atk":
			Keeper.set_value("tealwyv_player_store", "attack", val)
		"def":
			Keeper.set_value("tealwyv_player_store", "defense", val)
		"hp":
			Keeper.set_value("tealwyv_player_store", "hp_max", val)
		"level":
			if val < 1 or val > 12:
				output.text = "level must be between 1 and 12."
				return
			Keeper.set_value("_dev_store", "enemy_level", val)
		_:
			output.text = "unknown command. atk <n> | def <n> | hp <n> | level <n> | reset | exit"
			return
	_draw_menu()
	
func channel_shutdown() -> void:
	input.gui_input.disconnect(_on_gui_input)
