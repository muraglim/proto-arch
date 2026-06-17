class_name TealwyvTextDaemon
extends TealwyvDaemon

# Local cache — populated via signal on equipment change.
# HP evaluated at request time against Keeper, not cached.
var _weapon: String = ""
var _armor: String = ""

# Staleness tracking — ephemeral, resets on session start.
# _draw_count: global int that increments on every get_prompt() call.
# _last_used: maps global prompt index -> _draw_count value at time of last use.
var _draw_count: int = 0
var _last_used: Dictionary = {}

func daemon_init() -> void:
	_weapon = get_character_value("weapon")
	_armor = get_character_value("armor")

func on_equipment_changed() -> void:
	_weapon = Keeper.get_value("tealwyv_character_store", "weapon")
	_armor = Keeper.get_value("tealwyv_character_store", "armor")

func get_prompt(context: String) -> String:
	var hp = get_character_value("hp")
	var hp_max = get_character_value("hp_max")
	var hp_ratio: float = float(hp) / float(hp_max) if hp_max > 0 else 1.0
	var pool = _filter_pool(context, hp_ratio)
	if pool.is_empty():
		_log("get_prompt(context: %s): no eligible prompts found" % context)
		return ""
	var entry = _weighted_pick(context, pool)
	_draw_count += 1
	return _compose(entry)

func _weighted_pick(context: String, pool: Array) -> Dictionary:
	# candidates is the full unfiltered array — needed for stable global indexing.
	# pool may be a subset of it (tag filtering), so we resolve global index
	# per entry rather than using pool position directly.
	var candidates = Firm.get_value("tealwyv_text_ledger", context)
	var weights: Array[float] = []
	for i in pool.size():
		var global_index = candidates.find(pool[i])
		var last = _last_used.get(global_index, -1)
		# delta: how many draws ago this prompt was last used.
		# never-used entries get _draw_count + 1, a slight edge over everything else.
		var delta = _draw_count - last if last >= 0 else _draw_count + 1
		_log("  index %d | last_used: %d | delta: %d" % [global_index, last, delta])
		weights.append(float(delta))
	# after the for loop closes:
	_log("_weighted_pick(): weights for pool of %d: %s" % [pool.size(), weights])
	# weighted random draw: roll against the total, walk the cumulative sum.
	var total = weights.reduce(func(a, b): return a + b, 0.0)
	var roll = randf() * total
	var cursor = 0.0
	for i in weights.size():
		cursor += weights[i]
		if roll <= cursor:
			var global_index = candidates.find(pool[i])
			_last_used[global_index] = _draw_count
			_log("_weighted_pick(): picked index %d at draw %d" % [global_index, _draw_count])
			return pool[i]
	# fallback: floating point accumulation can leave roll marginally above cursor
	# at the final entry. return last element and record it.
	var fallback = pool[pool.size() - 1]
	_last_used[candidates.find(fallback)] = _draw_count
	return fallback

# currently dead code for filtering tags/low hp
func _filter_pool(context: String, hp_ratio: float) -> Array:
	var candidates = Firm.get_value("tealwyv_text_ledger", context)
	if candidates == null:
		_log("_filter_pool(context: %s): no pool found in Firm" % context)
		return []
	return candidates.filter(func(entry):
		if entry.get("tags", []).has("$LowHP") and hp_ratio >= 0.3:
			return false
		if entry.get("tags", []).has("$Blade") and _weapon != "blade":
			return false
		if entry.get("tags", []).has("$Blunt") and _weapon != "blunt":
			return false
		return true
	)

func _compose(entry: Dictionary) -> String:
	var text = entry.get("text", "")
	var args = entry.get("format_args", [])
	if args.is_empty():
		return text
	var resolved = args.map(func(arg):
		match arg:
			"weapon": return _weapon
			"armor": return _armor
			_:
				_log("_compose(): unresolved format arg: %s" % arg)
				return "???"
	)
	return text % resolved

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)
