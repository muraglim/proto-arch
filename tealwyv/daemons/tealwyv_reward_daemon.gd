class_name TealwyvRewardDaemon
extends TealwyvDaemon

func resolve_reward(enemy: Dictionary) -> Dictionary:
# dispatch point for event types - combat is the only branch built out.
# future event types get their own _resolve_* branches here.
	return _resolve_combat_reward(enemy)

func _resolve_combat_reward(enemy: Dictionary) -> Dictionary:
	var exp_gain = enemy["exp"]
	var gold_gain = enemy["gold"]
	offset_character_value("experience", float(exp_gain))
	offset_character_value("gold", float(gold_gain))
	return {"experience": exp_gain, "gold": gold_gain}

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): reward daemon offline.")
