class_name PaleolithDevStore
extends AutoSaveStore

func _init_defaults() -> void:
	data = {
		"time_scale": 1.0,
		"gather_bypass": false,  # true → 100% success rate
	}
