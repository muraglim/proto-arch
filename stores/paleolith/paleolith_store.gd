class_name PaleolithStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"day": 1,
		"elapsed": 0.0,
		"weather": "clear",
		"flint": 0,
		"tinder": 0,
		"has_fire": false,
		"revealed_deities": [],
		# shelter
		"shelter_location": "",
		"shelter_exists": false,
		"shelter_quality": 0.0,
		"shelter_stockpile": 0,
		"thicket_familiarity": 0.0,
	}
