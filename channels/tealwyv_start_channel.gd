class_name TealwyvStartChannel
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
	var active_profile_name = active_profile.get("name", "none")

	var active_character_name = "none"
	var active_character_id = Keeper.get_value("tealwyv_character_store", "active_character_id")
	if not active_character_id.is_empty():
		var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
		for character in characters:
			if character["id"] == active_character_id and character["profile_id"] == Profile.get_active_profile_id():
				active_character_name = character["name"]
				break

	output.text = "Active profile: %s\nActive character: %s\n\n[C]reate character / [S]elect character" % [active_profile_name, active_character_name]

func _on_input_changed(text: String) -> void:
	input.text = ""
	var action = text.strip_edges().to_lower()
	match action:
		"c":
			Nav.to_swap(self, get_nav("tealwyv_character_creation_channel"), SwapAction.SWAP)
		"s":
			Nav.to_swap(self, get_nav("tealwyv_character_selection_channel"), SwapAction.SWAP)

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)

func channel_resume() -> void:
	_update_display()
