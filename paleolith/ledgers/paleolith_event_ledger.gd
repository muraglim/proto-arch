class_name PaleolithEventLedger
extends Ledger

func _ready() -> void:
	data = {
		"roll_order": ["unguarded_nest"],

		"unguarded_nest": {
			"prd_c": 0.25,
			"contexts": ["travel", "return"],
			"yield_min": 1,
			"yield_max": 3,
			"pursuit_base": 0.3,
			"pursuit_two_eggs_modifier": 0.2,
			"pursuit_drink_modifier": 0.15,
			"text_key": "paleolith_event_nest_found",
			"location_weights": {
				"acacia_thicket": 1.0,
				"scrubland": 0.8,
				"riverbank": 0.4,
		},
	},
}
