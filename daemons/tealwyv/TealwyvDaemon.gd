class_name TealwyvDaemon
extends Daemon

func get_character_value(field: String, default_value = null) -> Variant:
	var character = _get_active_character()
	if character.is_empty():
		return default_value
	return character.get(field, default_value)

func set_character_value(field: String, value: Variant) -> void:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_id = Keeper.get_value("tealwyv_character_store", "active_character_id")
	for character in characters:
		if character["id"] == active_id:
			character[field] = value
			Keeper.set_value("tealwyv_character_store", "characters", characters)
			return
	push_error("[%s] set_character_value(field: %s): no active character found" % [name, field])

func offset_character_value(field: String, delta: float) -> void:
	var current = get_character_value(field)
	if Guard.is_unresolved(current, name + ":offset_character_value"): return
	if not current is float and not current is int:
		_log("offset_character_value(field: %s): value is not numeric, got %s" % [field, type_string(typeof(current))])
		return
	set_character_value(field, float(current) + delta)

func heal_full_hp() -> void:
	var hp_max = get_character_value("hp_max")
	set_character_value("hp", hp_max)

func _get_active_character() -> Dictionary:
	var characters = Keeper.get_value("tealwyv_character_store", "characters", [])
	var active_id = Keeper.get_value("tealwyv_character_store", "active_character_id")
	for character in characters:
		if character["id"] == active_id:
			return character
	return {}