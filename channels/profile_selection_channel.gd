class_name ProfileSelectionChannel
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
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	var lines: Array = []
	for profile in profiles:
		lines.append(profile["name"])
	output.text = "\n".join(lines) + "\n\nType a profile name to select it:"

func _on_text_submitted(text: String) -> void:
	var profile_name = text.strip_edges().to_lower()
	input.text = ""
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	for profile in profiles:
		if profile["name"].to_lower() == profile_name:
			Keeper.set_value("profile_store", "active_profile_id", profile["id"])
			Nav.to_swap(self, get_nav("project_start_channel"), SwapAction.EXIT)
			return
	# no match — silent failure, user retries

func channel_shutdown() -> void:
	input.text_submitted.disconnect(_on_text_submitted)
