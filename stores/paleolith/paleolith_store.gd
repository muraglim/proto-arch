class_name PaleolithStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"day": 1,
		"elapsed": 0.0,
		"weather": "clear",
		"flint": 0,
		"tinder": 0,
		"branches": 0,
		"acacia_gum": 0,
		"sedge_corms": 0,
		"crayfish": 0,
		"eggs": 0,
		"has_fire": false,
		"revealed_deities": [],
		# shelter
		"shelter_location": "",
		"shelter_exists": false,
		"shelter_quality": 0.0,
		"thicket_familiarity": 0.0,
	}
