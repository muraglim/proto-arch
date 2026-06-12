extends Node

# Profile is the read-only facade for ProfileStore.
# Mirrors Keeper/Firm conventions but scoped to a single store —
# exists to give cross-context callers (Tealwyv, future prototypes)
# a stable access point without reaching into Keeper directly
# or knowing ProfileStore's node name.
# Writes to profile_store remain in ProfileCreationChannel/ProfileSelectionChannel.

func get_active_profile() -> Dictionary:
	var active_id = Keeper.get_value("profile_store", "active_profile_id")
	if active_id == null or active_id.is_empty():
		return {}
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	for profile in profiles:
		if profile["id"] == active_id:
			return profile
	push_error("[Profile] get_active_profile(): active_profile_id '%s' set but no matching profile record found." % active_id)
	return {}

func get_active_profile_id() -> String:
	return Keeper.get_value("profile_store", "active_profile_id", "")
