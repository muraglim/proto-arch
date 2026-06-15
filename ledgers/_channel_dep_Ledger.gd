class_name _channel_dep_Ledger
extends Ledger

func _ready() -> void:
	data = {
		"tealwyv_forest_channel": [
			{"dest": "tealwyv_luck_daemon", "order": 0, "role": "luck"},
			{"dest": "tealwyv_text_daemon",  "order": 1, "role": "text"},
			{"dest": "tealwyv_combat_daemon","order": 2, "role": "combat"},
			{"dest": "tealwyv_event_roll_daemon", "order": 3, "role": "event_roll"},
			{"dest": "tealwyv_reward_daemon", "order": 3, "role": "reward"}
		],
	}
