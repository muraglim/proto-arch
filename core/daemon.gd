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

func nav_exit(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_exit"): return
	nav_req.emit(dest)

func get_nav(key: String) -> String:
	var path = Keeper.get_value("nav_store", key)
	if path == null or path.is_empty():
		push_error(name + ": failed to retrieve uid for key - " + key)
		return ""
	return path

func offset_value(store: String, key: String, delta: float) -> void:
	var current = Keeper.get_value(store, key)
	if Guard.is_unresolved(current, name + ":offset value"): return
	Keeper.set_value(store, key, current + delta)

signal nav_req(target_dest: String)