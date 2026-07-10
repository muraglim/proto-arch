class_name TealwyvEventRollDaemon
extends Daemon

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): event roll daemon offline.")

func roll_event() -> Dictionary:
# dispatch point for event types - combat is the only branch built out.
# future event types (treasure, ambush, nothing-happens, etc.) get their
# own _roll_* branches here as they're designed.
	return _roll_combat_encounter()

func _roll_combat_encounter() -> Dictionary:
	var all_enemies: Array = Firm.get_value("tealwyv_combat_ledger", "enemies")
	var dev_level: int = Keeper.get_value("tealwyv_dev_store", "enemy_level")
	var target_level: int = dev_level if dev_level > 0 else 1
	var pool: Array = all_enemies.filter(func(e): return e["level"] == target_level)
	var enemy: Dictionary = pool[randi() % pool.size()].duplicate()
	enemy["hp"] = ceil(enemy["hp"])
	enemy["attack"] = floor(enemy["attack"])
	enemy["defense"] = floor(enemy["defense"])
	return enemy
