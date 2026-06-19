class_name ProfileDaemon
extends Daemon

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): profile daemon offline.")

func submit_creation(profile_name: String) -> void:
	if profile_name.is_empty():
		creation_failed.emit("profile_creation_empty")
		return
	var forbidden_chars = Firm.get_value("profile_ledger", "forbidden_chars")
	for ch in forbidden_chars:
		if profile_name.contains(ch):
			creation_failed.emit("profile_creation_forbidden")
			return
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	for profile in profiles:
		if profile["name"].to_lower() == profile_name.to_lower():
			creation_failed.emit("profile_creation_taken")
			return
	_create_profile(profile_name)

func _create_profile(profile_name: String) -> void:
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	var new_id = "%d_%d" % [Time.get_unix_time_from_system(), randi()]
	var new_profile = {
		"id": new_id,
		"name": profile_name,
		"born_at": Time.get_datetime_string_from_system(),
	}
	profiles.append(new_profile)
	Keeper.set_value("profile_store", "profiles", profiles)
	Keeper.set_value("profile_store", "active_profile_id", new_id)
	creation_succeeded.emit()

func submit_selection(profile_name: String) -> void:
	var profiles = Keeper.get_value("profile_store", "profiles", [])
	for profile in profiles:
		if profile["name"].to_lower() == profile_name:
			Keeper.set_value("profile_store", "active_profile_id", profile["id"])
			selection_succeeded.emit()
			return

@warning_ignore("unused_signal")
signal creation_failed(error_key: String)
@warning_ignore("unused_signal")
signal creation_succeeded
@warning_ignore("unused_signal")
signal selection_succeeded
