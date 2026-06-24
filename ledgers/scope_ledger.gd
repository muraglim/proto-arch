class_name ScopeLedger
extends Ledger

func _ready() -> void:
	data = {
		"project_start": ["profile", "tealwyv_start", "paleolith_hub"],
		"profile": ["project_start"],
		"tealwyv_start": ["project_start", "tealwyv_hub"],
		"tealwyv_hub": ["tealwyv_start", "tealwyv_event"],
		"tealwyv_event": ["tealwyv_hub"],
		"paleolith_hub": ["project_start", "paleolith_pocket"],
		"paleolith_pocket": ["paleolith_hub"],
	}
