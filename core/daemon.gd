class_name Daemon
extends Node

# Do not use _ready() in Daemon subclasses
# Do not place anything that requires a Daemon's dependencies in daemon_init()
# Dependency wiring happens after daemon_init()

# Daemons interact with persistent state via Keeper directly.
# Keeper.get_value(), Keeper.set_value(), Keeper.append_value()
# Do not add data primitive wrappers here.

@export var verbose := true

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	pass

# offset_value lives here rather than Keeper — Keeper handles storage primitives only.
# Daemon computes the offset and passes the result to Keeper.set_value(), 
# keeping arithmetic out of the storage facade.
func offset_value(store: String, key: String, delta: float) -> void:
	var current = Keeper.get_value(store, key)
	if Guard.is_unresolved(current, name + ":offset_value"): return
	if not current is float and not current is int:
		_log("offset_value(store: %s, key: %s): value is not numeric, got %s" % [store, key, type_string(typeof(current))])
		return
	Keeper.set_value(store, key, float(current) + delta)

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)
