class_name TealwyvPlayerStatsChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	input.text_changed.connect(_on_input_changed)

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.max_length = 1
	input.grab_focus()
	_update_display()

func _update_display() -> void:
	var active_profile = Profile.get_active_profile()
	var profile_name = active_profile.get("name", "none")
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_id = Keeper.get_value("tealwyv_character_store", "active_character_id", "")
	var character: Dictionary = {}
	for c in characters:
		if c["id"] == active_id:
			character = c
			break
	if character.is_empty():
		output.text = "No active character.\n\n[B]ack"
		return
	output.text = "%s [%s] — %s\n\nATK: %d | DEF: %d\nWeapon: %s | Armor: %s\nBorn: %s\n\n[B]ack" % [
		character.get("name", "???"),
		character.get("class", "???"),
		profile_name,
		character.get("attack", 0),
		character.get("defense", 0),
		character.get("weapon", "???"),
		character.get("armor", "???"),
		character.get("born_at", "???"),
	]

func _on_input_changed(text: String) -> void:
	input.text = ""
	var action = text.strip_edges().to_lower()
	match action:
		"b":
			Nav.to_swap(self, return_dest, SwapAction.EXIT)

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)
