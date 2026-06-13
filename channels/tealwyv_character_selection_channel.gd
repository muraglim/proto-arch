class_name TealwyvCharacterSelectionChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	input.text_submitted.connect(_on_text_submitted)

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.grab_focus()
	_update_display()

func _update_display() -> void:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_profile_id = Profile.get_active_profile_id()
	var lines: Array = []
	for character in characters:
		if character["profile_id"] == active_profile_id:
			lines.append(character["name"])
	output.text = "\n".join(lines) + "\n\nType a character name to select it:"

func _on_text_submitted(text: String) -> void:
	var character_name = text.strip_edges().to_lower()
	input.text = ""
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_profile_id = Profile.get_active_profile_id()
	for character in characters:
		if character["profile_id"] == active_profile_id and character["name"].to_lower() == character_name:
			Keeper.set_value("tealwyv_character_store", "active_character_id", character["id"])
			Nav.to_swap(self, get_nav("tealwyv_start_channel"), SwapAction.EXIT)
			return
	# no match — silent failure, user retries

func channel_shutdown() -> void:
	input.text_submitted.disconnect(_on_text_submitted)
