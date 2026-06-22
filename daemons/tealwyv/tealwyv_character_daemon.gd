class_name TealwyvCharacterDaemon
extends Daemon

# Character lifecycle — create/select/list. Extends Daemon directly, not
# TealwyvDaemon: TealwyvDaemon's API (get_character_value, etc.) assumes a
# character is already active. This daemon decides which one is.
#
# Name uniqueness is global, not per-profile — the gameworld is a shared
# space (news feed, character-to-character interaction down the line), so
# two profiles can't claim the same character name. A profile may still
# own multiple characters.

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): character daemon offline.")

func submit_creation(character_name: String, gender: String) -> void:
	if character_name.is_empty():
		creation_failed.emit("tealwyv_character_creation_empty")
		return
	var forbidden_chars = Firm.get_value("tealwyv_character_ledger", "forbidden_chars")
	for ch in forbidden_chars:
		if character_name.contains(ch):
			creation_failed.emit("tealwyv_character_creation_forbidden")
			return
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	for character in characters:
		if character["name"].to_lower() == character_name.to_lower():
			creation_failed.emit("tealwyv_character_creation_taken")
			return
	_create_character(character_name, gender)

func _create_character(character_name: String, gender: String) -> void:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var starting_stats: Dictionary = Firm.get_value("tealwyv_character_ledger", "starting_stats")
	var new_id = "%d_%d" % [Time.get_unix_time_from_system(), randi()]
	var new_character = starting_stats.duplicate()
	new_character["id"] = new_id
	new_character["name"] = character_name
	new_character["gender"] = gender
	new_character["profile_id"] = Profile.get_active_profile_id()
	characters.append(new_character)
	Keeper.set_value("tealwyv_character_store", "characters", characters)
	Keeper.set_value("tealwyv_character_store", "active_character_id", new_id)
	creation_succeeded.emit()

func submit_selection(character_name: String) -> void:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_profile_id = Profile.get_active_profile_id()
	for character in characters:
		# name match AND profile match in one condition — a name that exists but
		# belongs to another profile fails the same way as a name that doesn't
		# exist at all, so selection can't be used to probe other profiles' rosters.
		if character["name"].to_lower() == character_name.to_lower() and character.get("profile_id") == active_profile_id:
			Keeper.set_value("tealwyv_character_store", "active_character_id", character["id"])
			selection_succeeded.emit()
			return
	selection_failed.emit("tealwyv_character_selection_missing")

@warning_ignore("unused_signal")
signal creation_failed(error_key: String)
@warning_ignore("unused_signal")
signal creation_succeeded
@warning_ignore("unused_signal")
signal selection_failed(error_key: String)
@warning_ignore("unused_signal")
signal selection_succeeded