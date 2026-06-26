class_name DepLedger
extends Ledger

func _ready() -> void:
	data = {
		"project_start_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "console_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "console_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "console_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "console_medium"},
				]
			},
		],
		"profile_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "console_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "console_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "console_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "console_medium"},
				]
			},
			{
				"uid_key": "profile_daemon",
				"type": "daemon",
				"role": "profile_daemon",
				"order": 2,
				"wires": [
					{"case": "call", "source": "self", "method": "set_daemon", "target": "profile_daemon"},
					{"case": "signal", "signal": "creation_failed", "target": "self", "method": "_on_creation_failed"},
					{"case": "signal", "signal": "creation_succeeded", "target": "self", "method": "_on_creation_succeeded"},
					{"case": "signal", "signal": "selection_succeeded", "target": "self", "method": "_on_selection_succeeded"},
				]
			},
		],
		"tealwyv_start_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "console_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "console_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "console_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "console_medium"},				
				]
			},
			{
				"uid_key": "tealwyv_character_daemon",
				"type": "daemon",
				"role": "tealwyv_character_daemon",
				"order": 2,
				"wires": [
					{"case": "call", "source": "self", "method": "set_daemon", "target": "tealwyv_character_daemon"},
					{"case": "signal", "signal": "creation_failed", "target": "self", "method": "_on_creation_failed"},
					{"case": "signal", "signal": "creation_succeeded", "target": "self", "method": "_on_creation_succeeded"},
					{"case": "signal", "signal": "selection_failed", "target": "self", "method": "_on_selection_failed"},
					{"case": "signal", "signal": "selection_succeeded", "target": "self", "method": "_on_selection_succeeded"},
				]
			},
		],
		"tealwyv_hub_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "console_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "console_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "console_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "console_medium"},
				]
			},
			{
				"uid_key": "tealwyv_event_lens",
				"type": "lens",
				"role": "tealwyv_event_lens",
				"order": 2,
				"wires": []
			},
			{
				"uid_key": "tealwyv_event_roll_daemon",
				"type": "daemon",
				"role": "tealwyv_event_roll_daemon",
				"order": 3,
				"wires": [
					{"case": "call", "source": "self", "method": "set_event_roll_daemon", "target": "tealwyv_event_roll_daemon"},
				]
			},
			{
				"uid_key": "tealwyv_text_daemon",
				"type": "daemon",
				"role": "tealwyv_text_daemon",
				"order": 5,
				"wires": [
					{"case": "call", "source": "self", "method": "set_text_daemon", "target": "tealwyv_text_daemon"},
				]
			},
		],
		"tealwyv_event_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "console_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "console_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "console_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "console_medium"},
				]
			},
			{
				"uid_key": "tealwyv_combat_daemon",
				"type": "daemon",
				"role": "tealwyv_combat_daemon",
				"order": 2,
				"wires": [
					{"case": "call", "source": "self", "method": "set_combat_daemon", "target": "tealwyv_combat_daemon"},
					{"case": "signal", "signal": "combat_event", "target": "self", "method": "_on_combat_event"},
				]
			},
			{
				"uid_key": "tealwyv_luck_daemon",
				"type": "daemon",
				"role": "tealwyv_luck_daemon",
				"order": 3,
				"wires": [
					{"case": "call", "source": "tealwyv_combat_daemon", "method": "wire_to_luck_daemon", "target": "tealwyv_luck_daemon"},
				]
			},
			{
				"uid_key": "tealwyv_reward_daemon",
				"type": "daemon",
				"role": "tealwyv_reward_daemon",
				"order": 4,
				"wires": [
					{"case": "call", "source": "tealwyv_combat_daemon", "method": "wire_to_reward_daemon", "target": "tealwyv_reward_daemon"},
				]
			},
			{
				"uid_key": "tealwyv_log_daemon",
				"type": "daemon",
				"role": "tealwyv_log_daemon",
				"order": 5,
				"wires": [
					{"case": "signal", "source": "tealwyv_combat_daemon", "signal": "combat_concluded", "target": "tealwyv_log_daemon", "method": "_on_combat_concluded"},
				]
			},
		],
		"paleolith_hub_lens": [
			{
				"uid_key": "paleolith_channel",
				"type": "channel",
				"role": "paleolith_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "paleolith_medium",
				"type": "geist",
				"role": "paleolith_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "paleolith_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "paleolith_medium"},
					{"case": "signal", "signal": "animation_complete", "target": "self", "method": "_on_animation_complete"},
				]
			},
			{
				"uid_key": "paleolith_tick_daemon",
				"type": "daemon",
				"role": "paleolith_tick_daemon",
				"order": 2,
				"wires": [
					{"case": "call", "source": "self", "method": "set_tick_daemon", "target": "paleolith_tick_daemon"},
				]
			},
			{
				"uid_key": "paleolith_gather_daemon",
				"type": "daemon",
				"role": "paleolith_gather_daemon",
				"order": 3,
				"wires": [
					{"case": "call", "source": "self", "method": "set_gather_daemon", "target": "paleolith_gather_daemon"},
					{"case": "signal", "signal": "gather_succeeded", "target": "self", "method": "_on_gather_succeeded"},
					{"case": "signal", "signal": "gather_failed", "target": "self", "method": "_on_gather_failed"},
				]
			},
			{
				"uid_key": "paleolith_fire_daemon",
				"type": "daemon",
				"role": "paleolith_fire_daemon",
				"order": 4,
				"wires": [
					{"case": "call", "source": "self", "method": "set_fire_daemon", "target": "paleolith_fire_daemon"},
					{"case": "signal", "signal": "fire_succeeded", "target": "self", "method": "_on_fire_succeeded"},
					{"case": "signal", "signal": "fire_failed", "target": "self", "method": "_on_fire_failed"},
				]
			},
			{
				"uid_key": "paleolith_deity_daemon",
				"type": "daemon",
				"role": "paleolith_deity_daemon",
				"order": 5,
				"wires": [
					{"case": "call", "source": "self", "method": "set_deity_daemon", "target": "paleolith_deity_daemon"},
					{"case": "signal", "source": "paleolith_fire_daemon", "signal": "fire_succeeded", "target": "paleolith_deity_daemon", "method": "on_fire_lit"},
					{"case": "signal", "signal": "deity_revealed", "target": "self", "method": "_on_deity_revealed"},
				]
			},
			{
				"uid_key": "paleolith_shelter_daemon",
				"type": "daemon",
				"role": "paleolith_shelter_daemon",
				"order": 6,
				"wires": [
					{"case": "call", "source": "self", "method": "set_shelter_daemon", "target": "paleolith_shelter_daemon"},
					{"case": "call", "source": "paleolith_shelter_daemon", "method": "set_tick_daemon", "target": "paleolith_tick_daemon"},
					{"case": "signal", "signal": "shelter_built", "target": "self", "method": "_on_shelter_built"},
					{"case": "signal", "signal": "shelter_degraded", "target": "self", "method": "_on_shelter_degraded"},
					{"case": "signal", "signal": "shelter_destroyed", "target": "self", "method": "_on_shelter_destroyed"},
					{"case": "signal", "source": "paleolith_tick_daemon", "signal": "tick", "target": "paleolith_shelter_daemon", "method": "on_tick"},
					{"case": "signal", "source": "paleolith_tick_daemon", "signal": "day_rolled", "target": "paleolith_shelter_daemon", "method": "on_day_rolled"},
				]
			},
			{
    			"uid_key": "paleolith_arc_medium",
    			"type": "geist",
    			"role": "paleolith_arc_medium",
    			"order": 7,
    			"wires": [
        			{"case": "call", "method": "set_channel", "target": "paleolith_channel"},
        			{"case": "signal", "source": "paleolith_tick_daemon", "signal": "tick", "target": "paleolith_arc_medium", "method": "on_tick"},
    			]
			},
			{
    			"uid_key": "paleolith_status_medium",
    			"type": "geist",
    			"role": "paleolith_status_medium",
    			"order": 8,
    			"wires": [
        			{"case": "call", "method": "set_channel", "target": "paleolith_channel"},
        			{"case": "signal", "source": "paleolith_tick_daemon", "signal": "tick", "target": "paleolith_status_medium", "method": "on_tick"},
    			]
			},
		],
		"paleolith_pocket_lens": [
			{
				"uid_key": "paleolith_channel",
				"type": "channel",
				"role": "paleolith_channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "paleolith_medium",
				"type": "geist",
				"role": "paleolith_medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "paleolith_channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "paleolith_medium"},
				]
			},
		],
	}
