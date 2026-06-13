class_name TealwyvCharacterStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"characters": [],
		"active_character_id": "",
	}

func _generate_id() -> String:
	return "%d_%d" % [Time.get_unix_time_from_system(), randi()]
