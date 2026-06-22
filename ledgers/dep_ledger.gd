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
	}
