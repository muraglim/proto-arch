class_name ProfileCreationChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	input.text_submitted.connect(_on_text_submitted)

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var max_len = Firm.get_value("profile_ledger", "max_name_length")
	input.max_length = max_len
	input.grab_focus()
	output.text = "Enter a name for your new profile (max %d characters):" % max_len

func _on_text_submitted(text: String) -> void:
	var profile_name = text.strip_edges()
	var max_len = Firm.get_value("profile_ledger", "max_name_length")
	var forbidden_chars = Firm.get_value("profile_ledger", "forbidden_chars")

	if profile_name.is_empty():
		output.text = "Name cannot be empty. Try again:"
		input.text = ""
		return

	for ch in forbidden_chars:
		if profile_name.contains(ch):
			output.text = "Name contains a forbidden character. Forbidden characters: %s\n\nTry again:" % " ".join(forbidden_chars)
			input.text = ""
			return

	var profiles = Keeper.get_value("profile_store", "profiles", [])
	for profile in profiles:
		if profile["name"].to_lower() == profile_name.to_lower():
			output.text = "That name is already taken. Try again:"
			input.text = ""
			return

	if profile_name.length() == max_len:
		output.text = "Note: %d characters is the maximum length." % max_len

	_create_profile(profile_name)

func _create_profile(profile_name: String) -> void:
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	var new_id = "%d_%d" % [Time.get_unix_time_from_system(), randi()]
	var new_profile = {
		"id": new_id,
		"name": profile_name,
		"born_at": Time.get_datetime_string_from_system(),
	}
	profiles.append(new_profile)
	Keeper.set_value("profile_store", "profiles", profiles)
	Keeper.set_value("profile_store", "active_profile_id", new_id)
	Nav.to_swap(self, get_nav("project_start_channel"), SwapAction.EXIT)

func channel_shutdown() -> void:
	input.text_submitted.disconnect(_on_text_submitted)
