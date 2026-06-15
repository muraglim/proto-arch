class_name TealwyvRewardDaemon
extends TealwyvDaemon

func wire_to_channel(channel: Channel) -> void:
	var forest = channel as TealwyvForestChannel
	if forest == null: return
	forest.register_reward_daemon(self)

func resolve_reward(enemy: Dictionary) -> Dictionary:
# dispatch point for event types - combat is the only branch built out.
# future event types get their own _resolve_* branches here.
	return _resolve_combat_reward(enemy)

func _resolve_combat_reward(enemy: Dictionary) -> Dictionary:
# currently lives as offset_character_value("experience"/"gold") calls
# in combat_daemon._resolve_victory()
	return {}

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): reward daemon offline.")
