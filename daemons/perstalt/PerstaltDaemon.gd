class_name PerstaltDaemon
extends Daemon

# Base for Perstalt gameplay daemons — analog of TealwyvDaemon, but flat:
# active-world state lives alone in the bound perstalt_save_store, so
# access is a direct key read, not an array scan.
#
# Profile guard baked in from day one (tealwyv's latent stale-pointer
# gap, fixed here by design): active_world_id surviving a profile switch
# yields {} / defaults instead of another profile's world.

func get_world_value(field: String, default_value = null) -> Variant:
	if not is_world_active():
		return default_value
	return Keeper.get_value("perstalt_save_store", field, default_value)

func set_world_value(field: String, value: Variant) -> void:
	if not is_world_active():
		push_error("[%s] set_world_value(field: %s): no valid active world" % [name, field])
		return
	Keeper.set_value("perstalt_save_store", field, value)

func get_active_world_meta() -> Dictionary:
	# Metadata record from the index — {} unless the active world exists
	# AND belongs to the active profile.
	var active_id = Keeper.get_value("perstalt_world_store", "active_world_id", "")
	if active_id.is_empty():
		return {}
	var worlds = Keeper.get_value("perstalt_world_store", "worlds", [])
	for world in worlds:
		if world["id"] == active_id and world.get("profile_id") == Profile.get_active_profile_id():
			return world
	return {}

func is_world_active() -> bool:
	if get_active_world_meta().is_empty():
		return false
	var save_store = Keeper.get_store("perstalt_save_store")
	return save_store != null and save_store.is_bound()
