class_name TealwyvCharacterStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"characters": [],
		"active_character_id": "",
	}
