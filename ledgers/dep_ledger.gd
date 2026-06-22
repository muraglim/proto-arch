class_name DepLedger
extends Ledger

func _ready() -> void:
	data = {
		"project_start_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},
				]
			},
		],
		"profile_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},
				]
			},
			{
				"uid_key": "profile_daemon",
				"type": "daemon",
				"role": "daemon",
				"order": 2,
				"wires": [
					{"case": "call", "source": "self", "method": "set_daemon", "target": "daemon"},
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
				"role": "channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},				
				]
			},
			{
				"uid_key": "tealwyv_character_daemon",
				"type": "daemon",
				"role": "daemon",
				"order": 2,
				"wires": [
					{"case": "call", "source": "self", "method": "set_daemon", "target": "daemon"},
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
				"role": "channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},
				]
			},
			{
				"uid_key": "tealwyv_event_lens",
				"type": "lens",
				"role": "event",
				"order": 2,
				"wires": []
			},
		],
		"tealwyv_event_lens": [
			{
				"uid_key": "console_channel",
				"type": "channel",
				"role": "channel",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"uid_key": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "channel"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},
				]
			},
		],
	}
