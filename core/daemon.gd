class_name Daemon
extends Node

# Do not use _ready() in Daemon subclasses.
# Use daemon_init() instead - it fires after the daemon
# is fully added to the scene tree and bootstrapper wiring is complete.

# Daemons interact with persistent state via Keeper directly.
# Keeper.get_value(), Keeper.set_value(), Keeper.append_value()
# Do not add data primitive wrappers here.

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	pass

func daemon_pause() -> void:
	pass

func daemon_resume() -> void:
	pass

func get_nav(key: String) -> String:
	var entry = Keeper.get_value("nav_dest_store", key)
	if entry == null or not entry.has("uid") or entry["uid"].is_empty():
		push_error(name + ": failed to retrieve uid for key - " + key)
		return ""
	return entry["uid"]

func offset_value(store: String, key: String, delta: float) -> void:
	var current = Keeper.get_value(store, key)
	if Guard.is_unresolved(current, name + ":offset value"): return
	Keeper.set_value(store, key, current + delta)

# signals are emitted externally via Nav autoload — unused_signal warnings expected
@warning_ignore("unused_signal")
signal daemon_dismiss_sig
@warning_ignore("unused_signal")
signal nav_to_daemon_sig(dest: String)
@warning_ignore("unused_signal")
signal nav_to_swap_sig(dest: String)
@warning_ignore("unused_signal")
signal evict_back_channel_sig(dest: String)
# currently unused as boot starts through a Channel - might be needed in future
@warning_ignore("unused_signal")
signal nav_to_channel_sig(dest: String)
