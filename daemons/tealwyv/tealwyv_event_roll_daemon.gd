class_name TealwyvEventRollDaemon
extends Daemon

func wire_to_channel(channel: Channel) -> void:
	var forest = channel as TealwyvForestChannel
	if forest == null: return
	forest.register_event_roll_daemon(self)

func roll_event() -> Dictionary:
# dispatch point for event types - combat is the only branch built out.
# future event types (treasure, ambush, nothing-happens, etc.) get their
# own _roll_* branches here as they're designed.
	return _roll_combat_encounter()

func _roll_combat_encounter() -> Dictionary:
# extraction target for the "implement event subclass" commit -
# enemy selection currently lives in tealwyv_combat_daemon._roll_encounter()
	return {}

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): event roll daemon offline.")
