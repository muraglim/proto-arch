extends Store

func add_to_roster(named: String, id: int, gender: bool, origin: String, zodiac: float) -> void:
	if has_key(id):
		push_error("Roster_Store: id already exists - %s" % str(id))
		return
	data[id] = {"name": named, "identity": id, "gender": gender, "origin": origin, "zodiac": zodiac, "medals": []}
