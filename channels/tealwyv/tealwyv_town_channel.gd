class_name TealwyvTownChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	input.text_changed.connect(_on_input_changed)
	Nav.to_back_start(self, get_nav("tealwyv_forest_channel"))

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.max_length = 1
	input.grab_focus()
	_update_display()

func _update_display() -> void:
# array walk to get active_character/active_profile temporary,
# when Daemon -> Factory -> Manager -> Channel pipeline is built
# that info can be fed to the Channel by the Manager
	var active_profile = Profile.get_active_profile()
	var active_profile_name = active_profile.get("name", "none")

	var character_name = "none"
	var active_character_id = Keeper.get_value("tealwyv_character_store", "active_character_id")
	if not active_character_id.is_empty():
		var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
		for character in characters:
			if character["id"] == active_character_id:
				character_name = character["name"]
				break

	output.text = "Welcome to Town, %s.\nCharacter: %s\n\n[F]orest / [C]haracter select / [S]tats" % [active_profile_name, character_name]

func _on_input_changed(text: String) -> void:
	input.text = ""
	var action = text.strip_edges().to_lower()
	match action:
		"f":
			Nav.to_swap(self, get_nav("tealwyv_forest_channel"), SwapAction.SWAP)
		"c":
			Nav.to_swap(self, get_nav("tealwyv_start_channel"), SwapAction.SWAP)
		"s":
			Nav.to_swap_return(self, get_nav("tealwyv_player_stats_channel"), SwapAction.SWAP, get_nav("tealwyv_town_channel"))

func channel_shutdown() -> void:
	input.text_changed.disconnect(_on_input_changed)

func channel_resume() -> void:
	_update_display()
