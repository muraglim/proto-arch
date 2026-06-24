class_name PaleolithLedger
extends Ledger

func _ready() -> void:
	data = {
		# tick
		"day_duration_seconds": 4320.0,
		"tick_emit_interval": 1.0,
		"temp_chase_rate": 0.1,
		"temp_base_range": {"min": 12.0, "max": 28.0},

		# fire
		"fire_duration": 3.0,
		"fire_base_success_rate": 1,

		"weather_table": [
			{"weather": "clear",    "weight": 40.0, "temp_modifier":   5.0},
			{"weather": "overcast", "weight": 30.0, "temp_modifier":  -2.0},
			{"weather": "rain",     "weight": 20.0, "temp_modifier":  -6.0},
			{"weather": "storm",    "weight": 10.0, "temp_modifier": -12.0},
		],

		"temp_grades": [
			{"label": "Frigid",      "max":  5.0},
			{"label": "Cold",        "max": 12.0},
			{"label": "Cool",        "max": 18.0},
			{"label": "Comfortable", "max": 24.0},
			{"label": "Warm",        "max": 30.0},
			{"label": "Hot",         "max":  INF},
		],

		"time_labels": [
			{"label": "Night",     "max": 0.15},
			{"label": "Dawn",      "max": 0.25},
			{"label": "Morning",   "max": 0.45},
			{"label": "Midday",    "max": 0.55},
			{"label": "Afternoon", "max": 0.75},
			{"label": "Dusk",      "max": 0.85},
			{"label": "Night",     "max": 1.01},
		],

		# gathering
		"gather_duration_riverbank": 2.5,
		"gather_duration_scrubland": 2.0,
		"gather_base_success_rate": 0.6,
		# caps live here until upgrade mechanics warrant moving them to paleolith_store
		"flint_cap": 1000,
		"tinder_cap": 5,

		# typewriter dispatch — keyed by compose context_key, fallback to "default"
		"typewriter_configs": {
			"default":                             {"chars_per_second": 60.0, "initial_delay": 0.0},
			"paleolith_hub":                       {"chars_per_second": 60.0, "initial_delay": 0.0},
			"paleolith_gathering_start_riverbank": {"chars_per_second": 70.0, "initial_delay": 0.0},
			"paleolith_gathering_start_scrubland": {"chars_per_second": 70.0, "initial_delay": 0.0},
			"paleolith_gather_success_flint":      {"chars_per_second": 70.0, "initial_delay": 0.0},
			"paleolith_gather_success_tinder":     {"chars_per_second": 70.0, "initial_delay": 0.0},
			"paleolith_gather_fail_flint":         {"chars_per_second": 70.0, "initial_delay": 0.0},
			"paleolith_gather_fail_tinder":        {"chars_per_second": 70.0, "initial_delay": 0.0},
			"paleolith_fire_stub":                 {"chars_per_second": 30.0, "initial_delay": 0.5},
			"paleolith_fire_attempt":  			   {"chars_per_second": 50.0, "initial_delay": 0.0},
			"paleolith_fire_success":  			   {"chars_per_second": 40.0, "initial_delay": 0.8},
			"paleolith_fire_fail":     			   {"chars_per_second": 60.0, "initial_delay": 0.0},
			"paleolith_deity_reveal":  			   {"chars_per_second": 35.0, "initial_delay": 1.2},
			"paleolith_pocket_stub":   			   {"chars_per_second": 60.0, "initial_delay": 0.0},
			"paleolith_site_selection":        {"chars_per_second": 50.0, "initial_delay": 0.0},
			"paleolith_shelter_trip_clear":    {"chars_per_second": 55.0, "initial_delay": 0.0},
			"paleolith_shelter_trip_lost":     {"chars_per_second": 45.0, "initial_delay": 0.3},
			"paleolith_shelter_built":         {"chars_per_second": 40.0, "initial_delay": 0.6},
			"paleolith_shelter_destroyed":     {"chars_per_second": 50.0, "initial_delay": 0.3},
		},
# shelter sites
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
		"shelter_harvest_time": 120.0,
		"shelter_harvest_count": 3,
		"shelter_degradation_base": 0.0003,
		"shelter_weather_degradation": {
			"clear":    0.0,
			"overcast": 0.0,
			"rain":     0.10,
			"storm":    0.30,
		},
		"shelter_build_quality_min": 0.4,
		"shelter_build_quality_max": 1.0,
		"shelter_quality_grades": [
			{"label": "Precarious", "max": 0.25},
			{"label": "Rough",      "max": 0.50},
			{"label": "Solid",      "max": 0.75},
			{"label": "Sturdy",     "max": 1.01},
		],

		# familiarity
		"familiarity_increment": 0.25,
		"familiarity_decay_per_day": 0.15,
		"familiarity_travel_reduction": 0.4,

		# night travel
		"night_threshold": 0.82,
		"night_lost_chance": 0.35,
		"night_lost_familiarity_reduction": 0.20,
		"night_penalty_min": 60.0,
		"night_penalty_max": 200.0,
		}
