class_name ProjectStartChannel
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
	var active_id = Keeper.get_value("profile_store", "active_profile_id")
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	var active_name = "none"
	if not active_id.is_empty():
		for profile in profiles:
			if profile["id"] == active_id:
				active_name = profile["name"]
				break
	output.text = "Active profile: %s\n\n[C]reate profile / [S]elect profile" % active_name

func _on_input_changed(text: String) -> void:
	input.text = ""
	var action = text.strip_edges().to_lower()
	match action:
		"c":
			Nav.to_swap(self, get_nav("profile_creation_channel"), SwapAction.SWAP)
		"s":
			Nav.to_swap(self, get_nav("profile_selection_channel"), SwapAction.SWAP)

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)

func channel_resume() -> void:
	_update_display()
