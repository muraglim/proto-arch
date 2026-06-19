class_name _dep_Ledger
extends Ledger

func _ready() -> void:
	data = {
		"project_start_lens": [
			{
				"dest": "console_channel",
				"type": "channel",
				"role": "only",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"dest": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "only"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},
				]
			},
		],
		"profile_lens": [
			{
				"dest": "console_channel",
				"type": "channel",
				"role": "only",
				"order": 0,
				"wires": [
					{"case": "signal", "signal": "input_received", "target": "self", "method": "_on_input"},
				]
			},
			{
				"dest": "console_medium",
				"type": "geist",
				"role": "medium",
				"order": 1,
				"wires": [
					{"case": "call", "method": "set_channel", "target": "only"},
					{"case": "call", "source": "self", "method": "set_medium", "target": "medium"},
				]
			},
			{
				"dest": "profile_daemon",
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
	}
