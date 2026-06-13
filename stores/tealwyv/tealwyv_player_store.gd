class_name TealwyvPlayerStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"player_id": _generate_id(),
		"player_name": "",
		"hp": 20,
		"hp_max": 20,
		"attack": 3,
		"defense": 1,
		"gold": 0,
		"experience": 0,
		"weapon": "fists",
		"armor": "rags"
	}

func _generate_id() -> String:
	return "%d_%d" % [Time.get_unix_time_from_system(), randi()]
