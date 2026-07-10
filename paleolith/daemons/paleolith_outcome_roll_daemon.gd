class_name PaleolithOutcomeRollDaemon
extends Daemon

func daemon_init() -> void:
	_log("daemon_init(): outcome roll daemon online.")

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): outcome roll daemon offline.")

func roll_outcome(base_chance: float, modifiers: Array = []) -> bool:
	return Luck.proc_weighted(base_chance, modifiers)

# Dispatches resource mutations for a resolved event choice.
# Add new event_key branches as events are designed.
func apply_outcome(event_key: String, choice: String) -> void:
	match event_key:
		"unguarded_nest":
			_apply_unguarded_nest(choice)
		_:
			_log("apply_outcome(): unhandled event_key '%s'" % event_key)

func _apply_unguarded_nest(choice: String) -> void:
	match choice:
		"take_one", "drink_take_one":
			offset_value("paleolith_store", "eggs", 1.0)
		"take_two":
			offset_value("paleolith_store", "eggs", 2.0)
		"drink_only":
			pass  # stub: hunger refill when hunger system exists
		"ignore":
			pass
