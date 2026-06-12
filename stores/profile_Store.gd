class_name profile_Store
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"profiles": [],
		"active_profile_id": "",
	}
