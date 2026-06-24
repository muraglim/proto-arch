class_name PaleolithShelterDaemon
extends Daemon

var _tick_daemon: PaleolithTickDaemon = null

var _sites: Dictionary = {}
var _harvest_time: float = 0.0
var _harvest_count: int = 3
var _degradation_base: float = 0.0
var _weather_degradation: Dictionary = {}
var _build_quality_min: float = 0.4
var _build_quality_max: float = 1.0
var _familiarity_increment: float = 0.0
var _familiarity_ceiling: float = 1.0
var _familiarity_decay: float = 0.0
var _familiarity_travel_reduction: float = 0.0
var _night_threshold: float = 0.82
var _night_lost_chance: float = 0.35
var _night_lost_familiarity_reduction: float = 0.20
var _night_penalty_min: float = 60.0
var _night_penalty_max: float = 200.0

func set_tick_daemon(daemon: PaleolithTickDaemon) -> void:
	_tick_daemon = daemon

func daemon_init() -> void:
	_sites                       = Firm.get_value("paleolith_ledger", "shelter_sites")
	_harvest_time                = Firm.get_value("paleolith_ledger", "shelter_harvest_time")
	_harvest_count               = Firm.get_value("paleolith_ledger", "shelter_harvest_count")
	_degradation_base            = Firm.get_value("paleolith_ledger", "shelter_degradation_base")
	_weather_degradation         = Firm.get_value("paleolith_ledger", "shelter_weather_degradation")
	_build_quality_min           = Firm.get_value("paleolith_ledger", "shelter_build_quality_min")
	_build_quality_max           = Firm.get_value("paleolith_ledger", "shelter_build_quality_max")
	_familiarity_increment       = Firm.get_value("paleolith_ledger", "familiarity_increment")
	_familiarity_decay           = Firm.get_value("paleolith_ledger", "familiarity_decay_per_day")
	_familiarity_travel_reduction = Firm.get_value("paleolith_ledger", "familiarity_travel_reduction")
	_night_threshold             = Firm.get_value("paleolith_ledger", "night_threshold")
	_night_lost_chance           = Firm.get_value("paleolith_ledger", "night_lost_chance")
	_night_lost_familiarity_reduction = Firm.get_value("paleolith_ledger", "night_lost_familiarity_reduction")
	_night_penalty_min           = Firm.get_value("paleolith_ledger", "night_penalty_min")
	_night_penalty_max           = Firm.get_value("paleolith_ledger", "night_penalty_max")
	_log("daemon_init(): online.")

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): offline.")

# — site selection —

func select_site(site_key: String) -> void:
	if not _sites.has(site_key):
		push_error("[PaleolithShelterDaemon] select_site(): unknown site '%s'" % site_key)
		return
	Keeper.set_value("paleolith_store", "shelter_location", site_key)
	_log("select_site(): %s" % site_key)

# — travel and harvest —

func do_harvest_trip() -> Dictionary:
	# compound: travel to thicket → harvest → travel back
	# each leg independently rolls for night penalty
	var to_result: Dictionary = _do_travel(true)
	_tick_daemon.advance_time(_harvest_time)
	var from_result: Dictionary = _do_travel(false)
	var stockpile: int = Keeper.get_value("paleolith_store", "shelter_stockpile", 0)
	Keeper.set_value("paleolith_store", "shelter_stockpile", stockpile + 1)
	var lost: bool = to_result["lost"] or from_result["lost"]
	_log("do_harvest_trip(): stockpile now %d | lost: %s" % [stockpile + 1, lost])
	return {"lost": lost}

func _do_travel(increment_familiarity: bool) -> Dictionary:
	var site_key: String = Keeper.get_value("paleolith_store", "shelter_location", "")
	var site_config: Dictionary = _sites.get(site_key, {})
	var base_time: float = site_config.get("travel_time_base", 300.0)
	var familiarity: float = Keeper.get_value("paleolith_store", "thicket_familiarity", 0.0)
	var fam_factor: float = familiarity / _familiarity_ceiling
	var travel_time: float = base_time * (1.0 - fam_factor * _familiarity_travel_reduction)

	var lost: bool = false
	var extra_time: float = 0.0
	var tod: float = _tick_daemon.build_tick_payload()["time_of_day"]
	var is_night: bool = tod > _night_threshold or tod < 0.15
	if is_night:
		var chance: float = maxf(_night_lost_chance - fam_factor * _night_lost_familiarity_reduction, 0.0)
		if randf() < chance:
			lost = true
			extra_time = randf_range(_night_penalty_min, _night_penalty_max)

	_tick_daemon.advance_time(travel_time + extra_time)

	if increment_familiarity:
		var new_fam: float = minf(familiarity + _familiarity_increment, _familiarity_ceiling)
		Keeper.set_value("paleolith_store", "thicket_familiarity", new_fam)
		_log("_do_travel(): familiarity → %.2f" % new_fam)

	return {"lost": lost}

# — build —

func attempt_build() -> void:
	var stockpile: int = Keeper.get_value("paleolith_store", "shelter_stockpile", 0)
	if stockpile < _harvest_count:
		push_error("[PaleolithShelterDaemon] attempt_build(): insufficient stockpile (%d/%d)" % [stockpile, _harvest_count])
		return
	var quality: float = randf_range(_build_quality_min, _build_quality_max)
	Keeper.set_value("paleolith_store", "shelter_quality", quality)
	Keeper.set_value("paleolith_store", "shelter_exists", true)
	Keeper.set_value("paleolith_store", "shelter_stockpile", 0)
	shelter_built.emit(quality)
	_log("attempt_build(): quality %.2f" % quality)

# — degradation — driven by tick signal via dep_ledger wire

func on_tick(payload: Dictionary) -> void:
	if not Keeper.get_value("paleolith_store", "shelter_exists", false): return
	var site_key: String = Keeper.get_value("paleolith_store", "shelter_location", "")
	var rate_mod: float = _sites.get(site_key, {}).get("degradation_rate_modifier", 1.0)
	var quality: float = Keeper.get_value("paleolith_store", "shelter_quality", 0.0)
	var degrade: float = _degradation_base * rate_mod
	var weather: String = payload.get("weather", "clear")
	var weather_chance: float = _weather_degradation.get(weather, 0.0)
	if randf() < weather_chance:
		degrade += _degradation_base * rate_mod
	quality = maxf(quality - degrade, 0.0)
	Keeper.set_value("paleolith_store", "shelter_quality", quality)
	if quality <= 0.0:
		Keeper.set_value("paleolith_store", "shelter_exists", false)
		shelter_destroyed.emit()
		_log("on_tick(): shelter destroyed.")
	else:
		shelter_degraded.emit(quality)

# — familiarity decay — driven by day_rolled signal

func on_day_rolled(_day: int, _weather: String) -> void:
	var fam: float = Keeper.get_value("paleolith_store", "thicket_familiarity", 0.0)
	if fam <= 0.0: return
	var new_fam: float = maxf(fam - _familiarity_decay, 0.0)
	Keeper.set_value("paleolith_store", "thicket_familiarity", new_fam)
	_log("on_day_rolled(): familiarity decayed → %.2f" % new_fam)

@warning_ignore("unused_signal")
signal shelter_built(quality: float)
@warning_ignore("unused_signal")
signal shelter_degraded(quality: float)
@warning_ignore("unused_signal")
signal shelter_destroyed
