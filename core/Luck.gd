extends Node

var _prd_initial_cache: Dictionary = {}

func proc_prd(accumulator_key: String, prd_c: float) -> bool:
	var c_initial := _get_prd_initial(prd_c, accumulator_key)
	var current: float = Keeper.get_value("luck_store", accumulator_key, 0.0)
	if current == 0.0:
		current = c_initial
	if randf() < current:
		Keeper.set_value("luck_store", accumulator_key, c_initial)
		return true
	Keeper.set_value("luck_store", accumulator_key, minf(current + c_initial, 1.0))
	return false

func proc_weighted(base_chance: float, modifiers: Array = []) -> bool:
	var total := base_chance
	for m in modifiers:
		total += m
	return randf() < clampf(total, 0.0, 1.0)

func _get_prd_initial(prd_c: float, cache_key: String) -> float:
	if not _prd_initial_cache.has(cache_key):
		_prd_initial_cache[cache_key] = _solve_prd_initial(prd_c)
	return _prd_initial_cache[cache_key]

static func _solve_prd_initial(p: float) -> float:
	var c := p / 10.0
	var step := c
	while true:
		var expected := _expected_proc_rate(c)
		if abs(expected - p) < 0.0001: break
		if step < 1e-9: break  # float precision floor — accept best approximation
		c += step if expected < p else -step
		step *= 0.5
	return c

static func _expected_proc_rate(c: float) -> float:
	var cumulative := 1.0
	var expected := 0.0
	var n := 1
	var current_p := c
	while cumulative > 0.0001:
		var p_proc := minf(current_p, 1.0) * cumulative
		expected += n * p_proc
		cumulative *= (1.0 - minf(current_p, 1.0))
		current_p += c
		n += 1
	return 1.0 / expected
