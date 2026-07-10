class_name PaleolithDeityDaemon
extends Daemon

func daemon_init() -> void:
	_log("daemon_init(): online.")

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): offline.")

func on_fire_lit() -> void:
	_check_condition("fire")

func _check_condition(condition_key: String) -> void:
	var condition_map: Dictionary = Firm.get_value("paleolith_deity_ledger", "condition_map", {})
	var triggered_ids: Array = condition_map.get(condition_key, [])
	if triggered_ids.is_empty(): return
	var revealed: Array = Keeper.get_value("paleolith_store", "revealed_deities", [])
	var deities: Array = Firm.get_value("paleolith_deity_ledger", "deities", [])
	for deity_id in triggered_ids:
		if deity_id in revealed: continue
		for deity in deities:
			if deity["id"] == deity_id:
				revealed.append(deity_id)
				Keeper.set_value("paleolith_store", "revealed_deities", revealed)
				deity_revealed.emit(deity)
				_log("_check_condition(%s): revealed %s" % [condition_key, deity_id])

@warning_ignore("unused_signal")
signal deity_revealed(deity: Dictionary)
