class_name PaleolithShelterDaemon
extends Daemon

var _sites: Dictionary = {}
var _harvest_count: int = 3
var _degradation_base: float = 0.0
var _weather_degradation: Dictionary = {}
var _build_quality_min: float = 0.4
var _build_quality_max: float = 1.0

func daemon_init() -> void:
	_sites               = Firm.get_value("paleolith_location_ledger", "shelter_sites")
	_harvest_count       = Firm.get_value("paleolith_ledger", "shelter_harvest_count")
	_degradation_base    = Firm.get_value("paleolith_ledger", "shelter_degradation_base")
	_weather_degradation = Firm.get_value("paleolith_ledger", "shelter_weather_degradation")
	_build_quality_min   = Firm.get_value("paleolith_ledger", "shelter_build_quality_min")
	_build_quality_max   = Firm.get_value("paleolith_ledger", "shelter_build_quality_max")
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

# — build —

func attempt_build() -> void:
	var branches: int = Keeper.get_value("paleolith_store", "branches", 0)
	if branches < _harvest_count:
		push_error("[PaleolithShelterDaemon] attempt_build(): insufficient branches (%d/%d)" % [branches, _harvest_count])
		return
	var quality: float = randf_range(_build_quality_min, _build_quality_max)
	Keeper.set_value("paleolith_store", "branches", branches - _harvest_count)
	Keeper.set_value("paleolith_store", "shelter_exists", true)
	Keeper.set_value("paleolith_store", "shelter_quality", quality)
	shelter_built.emit(quality)
	_log("attempt_build(): quality %.2f" % quality)

# — tick —

func on_tick(payload: Dictionary) -> void:
	if not Keeper.get_value("paleolith_store", "shelter_exists", false): return
	var site_key: String = Keeper.get_value("paleolith_store", "shelter_location", "")
	var site_config: Dictionary = _sites.get(site_key, {})
	var modifier: float = site_config.get("degradation_rate_modifier", 1.0)
	var weather: String = payload.get("weather", "clear")
	var weather_mod: float = _weather_degradation.get(weather, 0.0)
	var quality: float = Keeper.get_value("paleolith_store", "shelter_quality", 0.0)
	quality = maxf(quality - (_degradation_base + weather_mod) * modifier, 0.0)
	Keeper.set_value("paleolith_store", "shelter_quality", quality)
	if quality <= 0.0:
		Keeper.set_value("paleolith_store", "shelter_exists", false)
		shelter_destroyed.emit()
		_log("on_tick(): shelter destroyed.")
	else:
		shelter_degraded.emit(quality)

@warning_ignore("unused_parameter")
func on_day_rolled(_day: int, _weather: String) -> void:
	pass

@warning_ignore("unused_signal")
signal shelter_built(quality: float)
@warning_ignore("unused_signal")
signal shelter_degraded(quality: float)
@warning_ignore("unused_signal")
signal shelter_destroyed()
