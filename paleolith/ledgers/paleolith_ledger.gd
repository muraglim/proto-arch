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

		# shelter simulation
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
		"shelter_harvest_time": 120.0,
		"shelter_harvest_count": 3,

		# night travel
		"night_threshold": 0.82,
		"night_lost_chance": 0.35,
		"night_lost_cache_reduction": 0.20,
		"night_penalty_min": 60.0,
		"night_penalty_max": 200.0,

		# typewriter dispatch
		"typewriter_configs": {
			"default":                             {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_hub":                       {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_success_flint":      {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_success_tinder":     {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_fail_flint":         {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_fail_tinder":        {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_fire_stub":                 {"chars_per_second": 200.0, "initial_delay": 0.5},
			"paleolith_fire_attempt":              {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_fire_success":              {"chars_per_second": 200.0, "initial_delay": 0.8},
			"paleolith_fire_fail":                 {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_deity_reveal":              {"chars_per_second": 200.0, "initial_delay": 1.2},
			"paleolith_pocket_stub":               {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_site_selection":            {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_shelter_trip_clear":        {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_shelter_trip_lost":         {"chars_per_second": 200.0, "initial_delay": 0.3},
			"paleolith_shelter_built":             {"chars_per_second": 200.0, "initial_delay": 0.6},
			"paleolith_shelter_destroyed":         {"chars_per_second": 200.0, "initial_delay": 0.3},
			"paleolith_gather_hub":                 {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_start_flint":         {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_start_tinder":        {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_start_acacia_gum":    {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_start_sedge_corms":   {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_start_crayfish":      {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_success_acacia_gum":  {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_success_sedge_corms": {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_success_crayfish":    {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_fail_acacia_gum":     {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_fail_sedge_corms":    {"chars_per_second": 200.0, "initial_delay": 0.0},
			"paleolith_gather_fail_crayfish":       {"chars_per_second": 200.0, "initial_delay": 0.0},
		},
	}
