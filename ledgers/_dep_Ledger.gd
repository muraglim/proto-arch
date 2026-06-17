class_name _dep_Ledger
extends Ledger

func _ready() -> void:
	data = {
		"tealwyv_town_channel": [
			{
				"dest": "tealwyv_luck_daemon",
				"order": 0,
				"role": "luck",
				"wires": []
			},
			{
				"dest": "tealwyv_text_daemon",
				"order": 1,
				"role": "text",
				"wires": []
			},
			{
				"dest": "tealwyv_reward_daemon",
				"order": 2,
				"role": "reward",
				"wires": []
			},
			{
				"dest": "tealwyv_combat_daemon",
				"order": 3,
				"role": "combat",
				"wires": [
					{"case": "call", "method": "wire_to_luck_daemon", "target": "luck"},
					{"case": "call", "method": "wire_to_reward_daemon", "target": "reward"},
				]
			},
			{
				"dest": "tealwyv_event_roll_daemon",
				"order": 4,
				"role": "event_roll",
				"wires": []
			},
			{
				"dest": "tealwyv_log_daemon",
				"order": 5,
				"role": "log",
				"wires": [
					{"case": "signal", "source": "combat", "signal": "combat_concluded", "target": "log", "method": "_on_combat_concluded"},
				]
			},
		],
		"tealwyv_forest_channel": [
			{
				"dest": "tealwyv_combat_daemon",
				"order": 0,
				"role": "combat",
				"wires": [
					{"case": "assign", "target": "channel", "property": "_combat_daemon"},
					{"case": "signal", "signal": "combat_event", "target": "channel", "method": "_on_combat_event"},
				]
			},
			{
				"dest": "tealwyv_event_roll_daemon",
				"order": 1,
				"role": "event_roll",
				"wires": [
					{"case": "assign", "target": "channel", "property": "_event_roll_daemon"},
				]
			},
			{
				"dest": "tealwyv_text_daemon",
				"order": 2,
				"role": "text",
				"wires": [
				{"case": "assign", "target": "channel", "property": "_text_daemon"},
				]
			},			
		],
	}
