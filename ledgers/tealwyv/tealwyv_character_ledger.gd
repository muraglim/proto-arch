class_name TealwyvCharacterLedger
extends Ledger

func _ready() -> void:
	data = {
		"max_name_length": 16,
		"forbidden_chars": ["/", "\\", "?", "*", ":", "|", "\"", "<", ">", "~"],
		"starting_stats": {
			"hp": 20.0,
			"hp_max": 20.0,
			"attack": 5.0,
			"defense": 2.0,
			"weapon": "dagger",
			"armor": "cloak",
			"gold": 0.0,
			"experience": 0.0,
		},
	}
