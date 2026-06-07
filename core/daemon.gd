class_name Daemon
extends Node

# Do not use _ready() in Daemon subclasses.
# Use daemon_init() instead - it fires after the daemon
# is fully added to the scene tree and bootstrapper wiring is complete.

# Daemons interact with persistent state via Keeper directly.
# Keeper.get_value(), Keeper.set_value(), Keeper.append_value()
# Do not add data primitive wrappers here.

@export var verbose := true

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	pass

func daemon_pause() -> void:
	pass

func daemon_resume() -> void:
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

# get_nav() and get_type() are duplicated from Daemon — residue of a prior Channel extends Daemon 
# relationship that caused scene construction errors. consolidate if a shared base becomes viable.
func get_nav(key: String) -> String:
	var entry = Firm.get_value("_nav_dest_ledger", key)
	if entry == null or not entry.has("uid") or entry["uid"].is_empty():
		_log("get_nav(key: %s): failed to retrieve uid" % key)
		return ""
	return entry["uid"]

func get_type(key: String) -> String:
	var entry = Keeper.get_value("_nav_dest_ledger", key)
	if entry == null or not entry.has("type"):
		_log("get_type(key: %s): no type found" % key)
		return ""
	return entry["type"]

func _connect_to_main(main: Node) -> void:
	nav_to_daemon.connect(main._on_nav_to_daemon)
	daemon_dismiss.connect(main._on_daemon_dismiss)
	nav_to_swap.connect(main._on_daemon_nav_to_swap)
	evict_back_channel.connect(main._on_evict_back_channel)

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)

# signals are emitted externally via Nav autoload — unused_signal warnings expected
@warning_ignore("unused_signal")
signal daemon_dismiss(dest: String)
@warning_ignore("unused_signal")
signal nav_to_daemon(dest: String)
@warning_ignore("unused_signal")
signal nav_to_swap(dest: String)
@warning_ignore("unused_signal")
signal evict_back_channel(dest: String)
# unused at boot — boot routes through Channel. available for Daemon-initiated Channel 
# navigation e.g. ambush triggers, sleep timers, any case where logic drives a front swap
# without Channel involvement.
@warning_ignore("unused_signal")
signal nav_to_channel(dest: String)
