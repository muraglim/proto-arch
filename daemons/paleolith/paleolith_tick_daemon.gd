class_name PaleolithTickDaemon
extends Daemon

# ledger constants cached at daemon_init — all immutable, safe to cache.
var _day_duration: float = 0.0
var _tick_emit_interval: float = 0.0
var _temp_chase_rate: float = 0.0
var _weather_table: Array = []
var _temp_grades: Array = []
var _time_labels: Array = []
var _temp_base_min: float = 0.0
var _temp_base_max: float = 0.0

# ephemeral state — not persisted. lives in daemon memory only.
var _elapsed: float = 0.0
var _emit_elapsed: float = 0.0
var _time_of_day: float = 0.0
var _ambient_temp: float = 0.0
var _character_temp: float = 0.0
var _weather: String = "clear"  # local cache; updated on day roll only.

func daemon_init() -> void:
	_day_duration = Firm.get_value("paleolith_ledger", "day_duration_seconds")
	_tick_emit_interval = Firm.get_value("paleolith_ledger", "tick_emit_interval")
	_temp_chase_rate = Firm.get_value("paleolith_ledger", "temp_chase_rate")
	_weather_table = Firm.get_value("paleolith_ledger", "weather_table")
	_temp_grades = Firm.get_value("paleolith_ledger", "temp_grades")
	_time_labels = Firm.get_value("paleolith_ledger", "time_labels")
	var range_data: Dictionary = Firm.get_value("paleolith_ledger", "temp_base_range")
	_temp_base_min = range_data["min"]
	_temp_base_max = range_data["max"]
	_weather = Keeper.get_value("paleolith_store", "weather", "clear")
	_update_ambient_temp()
	_character_temp = _ambient_temp
	_log("daemon_init(): online. ambient: %.1f° | character: %.1f°" % [_ambient_temp, _character_temp])

func daemon_shutdown() -> void:
	set_process(false)
	_log("daemon_shutdown(): offline.")

func _process(delta: float) -> void:
	var time_scale: float = Keeper.get_value("paleolith_dev_store", "time_scale", 1.0)
	var scaled_delta: float = delta * time_scale

	_elapsed += scaled_delta
	if _elapsed >= _day_duration:
		_elapsed -= _day_duration
		_advance_day()

	_time_of_day = _elapsed / _day_duration
	_update_ambient_temp()
	_chase_character_temp(delta)

	_emit_elapsed += delta
	if _emit_elapsed >= _tick_emit_interval:
		_emit_elapsed -= _tick_emit_interval
		var payload := build_tick_payload()
		_log("day %d | %s | %s | %.1f° (%s)" % [
			payload["day"], payload["time_label"], payload["weather"],
			payload["character_temp"], payload["temp_grade"]
		])
		tick.emit(payload)

func _advance_day() -> void:
	var current_day: int = Keeper.get_value("paleolith_store", "day", 1)
	Keeper.set_value("paleolith_store", "day", current_day + 1)
	_roll_weather()
	var new_day: int = Keeper.get_value("paleolith_store", "day")
	_log("_advance_day(): day %d | weather: %s" % [new_day, _weather])
	day_rolled.emit(new_day, _weather)

func _roll_weather() -> void:
	var total_weight: float = _weather_table.reduce(func(acc, e): return acc + e["weight"], 0.0)
	var roll: float = randf() * total_weight
	var cursor: float = 0.0
	for entry in _weather_table:
		cursor += entry["weight"]
		if roll < cursor:
			_weather = entry["weather"]
			Keeper.set_value("paleolith_store", "weather", _weather)
			return

func _update_ambient_temp() -> void:
	var sun_factor: float = sin(_time_of_day * PI)
	var base_temp: float = lerp(_temp_base_min, _temp_base_max, sun_factor)
	_ambient_temp = base_temp + _get_weather_modifier()

func _get_weather_modifier() -> float:
	for entry in _weather_table:
		if entry["weather"] == _weather:
			return entry["temp_modifier"]
	return 0.0

func _chase_character_temp(delta: float) -> void:
	# real (unscaled) delta — character temp responds to real time, not compressed game time.
	_character_temp = lerp(_character_temp, _ambient_temp, clamp(_temp_chase_rate * delta, 0.0, 1.0))

func build_tick_payload() -> Dictionary:
	return {
		"day":            Keeper.get_value("paleolith_store", "day", 1),
		"time_of_day":    _time_of_day,
		"time_label":     _get_time_label(),
		"weather":        _weather,
		"ambient_temp":   _ambient_temp,
		"character_temp": _character_temp,
		"temp_grade":     _get_temp_grade(_character_temp),
	}

func _get_time_label() -> String:
	for entry in _time_labels:
		if _time_of_day < entry["max"]:
			return entry["label"]
	return "Night"

func _get_temp_grade(temp: float) -> String:
	for entry in _temp_grades:
		if temp < entry["max"]:
			return entry["label"]
	return "Hot"

@warning_ignore("unused_signal")
signal tick(payload: Dictionary)
@warning_ignore("unused_signal")
signal day_rolled(day: int, weather: String)
