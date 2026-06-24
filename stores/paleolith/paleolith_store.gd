class_name PaleolithStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"day": 1,
		"weather": "clear",
		"flint": 0,
		"tinder": 0,
		"has_fire": false,
		"revealed_deities": [],
	}
