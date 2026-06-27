class_name PaleolithEventLedger
extends Ledger

func _ready() -> void:
	data = {
		"unguarded_nest": {
			"prd_c": 0.25,
			"yield_min": 1,
			"yield_max": 3,
			"text_key": "paleolith_event_nest_found",
			"location_weights": {
				"acacia_thicket": 1.0,
				"scrubland": 0.8,
				"riverbank": 0.4,
			},
		},
	}