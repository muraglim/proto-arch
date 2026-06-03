extends Store

# medals: Array — contents must be JSON-serializable primitives or dicts
func add_to_roster(named: String, id: String, gender: bool, origin: String, zodiac: float) -> void:
	if has_key(id):
		push_error("Roster_Store: id already exists - %s" % str(id))
		return
	data[id] = {"name": named, "identity": id, "gender": gender, "origin": origin, "zodiac": zodiac, "medals": []}
	print("Roster_Store: wrote - ", data[id])
