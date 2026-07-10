class_name PerstaltWorldDaemon
extends Daemon

# World lifecycle — create/select/delete. Extends Daemon directly, not
# PerstaltDaemon: PerstaltDaemon's API assumes a world is already active
# and bound. This daemon decides which one is. (Same reasoning as
# TealwyvCharacterDaemon vs TealwyvDaemon.)
#
# Name uniqueness is PER-PROFILE, deliberately diverging from tealwyv's
# global check — tealwyv characters share one gameworld; Perstalt worlds
# are private saves. Two profiles can each own a world named "Home".
#
# Binding: this daemon is the only writer of perstalt_save_store's
# slot binding. Uses Keeper.get_store() — a demonstrated use case for
# that escape hatch; promote to a Keeper facade method if preferred.

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): world daemon offline.")

func submit_creation(world_name: String) -> void:
	if Profile.get_active_profile_id().is_empty():
		creation_failed.emit("perstalt_world_creation_no_profile")
		return
	if world_name.is_empty():
		creation_failed.emit("perstalt_world_creation_empty")
		return
	var forbidden_chars = Firm.get_value("perstalt_world_ledger", "forbidden_chars")
	for ch in forbidden_chars:
		if world_name.contains(ch):
			creation_failed.emit("perstalt_world_creation_forbidden")
			return
	for world in _get_profile_worlds():
		if world["name"].to_lower() == world_name.to_lower():
			creation_failed.emit("perstalt_world_creation_taken")
			return
	_create_world(world_name)

func _create_world(world_name: String) -> void:
	var worlds = Keeper.get_value("perstalt_world_store", "worlds", [])
	var new_id = "%d_%d" % [Time.get_unix_time_from_system(), randi()]
	var new_world = {
		"id": new_id,
		"name": world_name,
		"profile_id": Profile.get_active_profile_id(),
		"seed": randi(), # cast int() at consumption — JSON floats this
		"created_at": Time.get_unix_time_from_system(),
	}
	worlds.append(new_world)
	Keeper.set_value("perstalt_world_store", "worlds", worlds)
	Keeper.set_value("perstalt_world_store", "active_world_id", new_id)
	_bind_save_store(new_id)
	creation_succeeded.emit()

func submit_selection(world_name: String) -> void:
	# name match scoped to active profile — a name belonging to another
	# profile fails identically to a name that doesn't exist.
	for world in _get_profile_worlds():
		if world["name"].to_lower() == world_name.to_lower():
			Keeper.set_value("perstalt_world_store", "active_world_id", world["id"])
			_bind_save_store(world["id"])
			selection_succeeded.emit()
			return
	selection_failed.emit("perstalt_world_selection_missing")

func submit_deletion(world_name: String) -> void:
	var target: Dictionary = {}
	for world in _get_profile_worlds():
		if world["name"].to_lower() == world_name.to_lower():
			target = world
			break
	if target.is_empty():
		deletion_failed.emit("perstalt_world_deletion_missing")
		return
	var save_store = Keeper.get_store("perstalt_save_store")
	if Keeper.get_value("perstalt_world_store", "active_world_id", "") == target["id"]:
		Keeper.set_value("perstalt_world_store", "active_world_id", "")
	save_store.delete_slot(target["id"]) # unbinds without saving if bound
	var worlds = Keeper.get_value("perstalt_world_store", "worlds", [])
	worlds = worlds.filter(func(w): return w["id"] != target["id"])
	Keeper.set_value("perstalt_world_store", "worlds", worlds)
	deletion_succeeded.emit()

func restore_active_binding() -> void:
	# Called on start-lens resume: the persisted active_world_id survives
	# sessions and profile switches; the save store's binding does not.
	# Rebind only if the pointer is valid for the CURRENT profile —
	# otherwise leave unbound (and don't clear the pointer: the other
	# profile may return to it).
	var save_store = Keeper.get_store("perstalt_save_store")
	var active_id = Keeper.get_value("perstalt_world_store", "active_world_id", "")
	if active_id.is_empty():
		if save_store.is_bound(): save_store.unbind()
		return
	for world in _get_profile_worlds():
		if world["id"] == active_id:
			if not save_store.is_bound():
				_bind_save_store(active_id)
			return
	# pointer belongs to another profile — ensure nothing leaks through
	if save_store.is_bound():
		save_store.unbind()

func _bind_save_store(world_id: String) -> void:
	var save_store = Keeper.get_store("perstalt_save_store")
	save_store.bind_slot(world_id)
	if Keeper.get_value("perstalt_save_store", "world_id", "") != world_id:
		Keeper.set_value("perstalt_save_store", "world_id", world_id)

func _get_profile_worlds() -> Array:
	var worlds = Keeper.get_value("perstalt_world_store", "worlds", [])
	var active_profile_id = Profile.get_active_profile_id()
	return worlds.filter(func(w): return w.get("profile_id") == active_profile_id)

@warning_ignore("unused_signal")
signal creation_failed(error_key: String)
@warning_ignore("unused_signal")
signal creation_succeeded
@warning_ignore("unused_signal")
signal selection_failed(error_key: String)
@warning_ignore("unused_signal")
signal selection_succeeded
@warning_ignore("unused_signal")
signal deletion_failed(error_key: String)
@warning_ignore("unused_signal")
signal deletion_succeeded
