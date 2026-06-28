class_name PaleolithEventRollDaemon
extends Daemon

func daemon_init() -> void:
	_log("daemon_init(): event roll daemon online.")

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): event roll daemon offline.")

func roll_for_event(context: String, location: String) -> Dictionary:
	var roll_order: Array = Firm.get_value("paleolith_event_ledger", "roll_order")
	for event_key in roll_order:
		var result := _roll_event(event_key, context, location)
		if not result.is_empty():
			return result
	return {}

func _roll_event(event_key: String, context: String, location: String) -> Dictionary:
	var data: Dictionary = Firm.get_value("paleolith_event_ledger", event_key)
	if data.is_empty(): return {}
	var contexts: Array = data.get("contexts", [])
	if not contexts.is_empty() and context not in contexts: return {}
	var weight: float = data.get("location_weights", {}).get(location, 0.0)
	if weight <= 0.0: return {}
	var prd_c: float = data.get("prd_c", 0.0) * weight
	if prd_c <= 0.0: return {}
	if Luck.proc_prd("prd_%s_%s" % [event_key, location], prd_c):
		_log("_roll_event(): %s fired at %s/%s" % [event_key, context, location])
		var result := data.duplicate()
		result["event_key"] = event_key
		return result
	return {}