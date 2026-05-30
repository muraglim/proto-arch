# TO-DO: pull-up module_exit from Module -> Daemon
# Daemon should be able to close Module from back
# the use case is relatively thin, but feasible. 

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

func daemon_exit() -> void:
	daemon_exit_sig.emit()

func nav_to_daemon(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_to_daemon"): return
	nav_to_daemon_sig.emit(dest)

func nav_to_module(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_to_module"): return
	nav_to_module_sig.emit(dest)

func nav_to_swap(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_to_swap"): return
	nav_to_swap_sig.emit(dest)

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

signal daemon_exit_sig
signal nav_to_daemon_sig(dest: String)
signal nav_to_module_sig(dest: String)
signal nav_to_swap_sig(dest: String)
