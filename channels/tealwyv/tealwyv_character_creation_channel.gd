class_name TealwyvCharacterCreationChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

var _pending_name: String = ""

func channel_init() -> void:
	input.text_submitted.connect(_on_text_submitted)
	input.text_changed.connect(_on_input_changed)

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var max_len = Firm.get_value("profile_ledger", "max_name_length")
	input.max_length = max_len
	input.grab_focus()
	output.text = "Enter a name for your new character (max %d characters):" % max_len

func _on_text_submitted(text: String) -> void:
	if not _pending_name.is_empty():
		return # name already accepted, awaiting class selection via _on_input_changed

	var character_name = text.strip_edges()
	var forbidden_chars = Firm.get_value("profile_ledger", "forbidden_chars")

	if character_name.is_empty():
		output.text = "Name cannot be empty. Try again:"
		input.text = ""
		return

	for ch in forbidden_chars:
		if character_name.contains(ch):
			output.text = "Name contains a forbidden character. Forbidden characters: %s\n\nTry again:" % " ".join(forbidden_chars)
			input.text = ""
			return

	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	for character in characters:
		if character["name"].to_lower() == character_name.to_lower():
			output.text = "That name is already taken. Try again:"
			input.text = ""
			return

	_pending_name = character_name
	input.max_length = 1
	input.text = ""
	output.text = "Choose a class:\n\n[W]arrior / [M]age / [T]hief"

func _on_input_changed(text: String) -> void:
	if _pending_name.is_empty():
		return # still awaiting name via _on_text_submitted

	input.text = ""
	var action = text.strip_edges().to_lower()
	var character_class = ""
	match action:
		"w": character_class = "warrior"
		"m": character_class = "mage"
		"t": character_class = "thief"
		_: return # not a recognized class key, ignore

	_create_character(_pending_name, character_class)

func _create_character(character_name: String, character_class: String) -> void:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var new_id = "%d_%d" % [Time.get_unix_time_from_system(), randi()]
	var new_character = {
		"id": new_id,
		"profile_id": Profile.get_active_profile_id(),
		"name": character_name,
		"class": character_class,
		"hp": 20,
		"hp_max": 20,
		"attack": 3,
		"defense": 1,
		"gold": 0,
		"experience": 0,
		"weapon": "fists",
		"armor": "rags",
		"born_at": Time.get_datetime_string_from_system(),
	}
	characters.append(new_character)
	Keeper.set_value("tealwyv_character_store", "characters", characters)
	Keeper.set_value("tealwyv_character_store", "active_character_id", new_id)
	Nav.to_swap(self, get_nav("tealwyv_start_channel"), SwapAction.EXIT)

func channel_shutdown() -> void:
	input.text_submitted.disconnect(_on_text_submitted)
	input.text_changed.disconnect(_on_input_changed)
