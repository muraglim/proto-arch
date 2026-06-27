class_name PaleolithLocationLedger
extends Ledger

func _ready() -> void:
	data = {
		# gather locations — material_node and food_node are keys into paleolith_resource_ledger
		"locations": {
			"acacia_thicket": {
				"label": "Acacia Thicket",
				"travel_time_base": 400.0,
				"material_node": "branches",
				"food_node": "acacia_gum",
				"event_eligible": true,
			},
			"scrubland": {
				"label": "Scrubland",
				"travel_time_base": 200.0,
				"material_node": "tinder",
				"food_node": "tubers",
				"event_eligible": true,
			},
			"riverbank": {
				"label": "Riverbank",
				"travel_time_base": 300.0,
				"material_node": "flint",
				"food_node": "crayfish",
				"event_eligible": true,
			},
		},

		# shelter sites — separate schema, different consumers
		"shelter_sites": {
			"exposed_ridge": {
				"label": "Exposed Ridge",
				"degradation_rate_modifier": 1.5,
				"travel_time_base": 300.0,
			},
			"sheltered_hollow": {
				"label": "Sheltered Hollow",
				"degradation_rate_modifier": 0.7,
				"travel_time_base": 500.0,
			},
		},

		# cache knowledge (was: familiarity)
		# travel_reduction applies to within-location harvest time, not travel time
		"cache_knowledge": {
			"increment": 0.25,
			"decay_per_day": 0.15,
			"travel_reduction": 0.4,
		},
	}
