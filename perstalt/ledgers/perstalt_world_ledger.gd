class_name PerstaltWorldLedger
extends Ledger

func _ready() -> void:
	data = {
		# mirror tealwyv_character_ledger's forbidden set if it differs —
		# braces are non-negotiable (they break String.format templates).
		"forbidden_chars": ["{", "}", "[", "]", "\\", "/"],
		"max_name_length": 20,
	}
