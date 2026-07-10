class_name profile_Ledger
extends Ledger

func _ready() -> void:
	data = {
		"max_name_length": 16,
		"forbidden_chars": ["/", "\\", "?", "*", ":", "|", "\"", "<", ">", "~"],
	}
