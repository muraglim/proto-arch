class_name ScopeLedger
extends Ledger

func _ready() -> void:
	data = {
		"project_start": ["profile"],
		"profile": ["project_start"],
	}
