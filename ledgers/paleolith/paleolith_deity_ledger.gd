class_name PaleolithDeityLedger
extends Ledger

func _ready() -> void:
	data = {
		"deities": [
			{
				"id": "ash_keeper",
				"name": "Ash-Keeper",
				"flavor": "Something ancient stirs in your embers — patient, watching.",
			},
		],
		"condition_map": {
			"fire": ["ash_keeper"],
		},
	}
