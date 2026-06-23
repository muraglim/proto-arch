class_name PaleolithGatherDaemon
extends Daemon

var _duration_riverbank: float = 0.0
var _duration_scrubland: float = 0.0
var _base_success_rate: float = 0.0

var _elapsed: float = 0.0
var _active_duration: float = 0.0
var _active_location: String = ""

func daemon_init() -> void:
	set_process(false)
	_duration_riverbank = Firm.get_value("paleolith_ledger", "gather_duration_riverbank")
	_duration_scrubland = Firm.get_value("paleolith_ledger", "gather_duration_scrubland")
	_base_success_rate = Firm.get_value("paleolith_ledger", "gather_base_success_rate")
	_log("daemon_init(): online.")

func daemon_shutdown() -> void:
	set_process(false)
	_log("daemon_shutdown(): offline.")

func start_gather(location: String) -> void:
	_active_location = location
	_active_duration = _duration_riverbank if location == "riverbank" else _duration_scrubland
	_elapsed = 0.0
	set_process(true)
	_log("start_gather(): %s (%.1fs)" % [location, _active_duration])

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _active_duration:
		set_process(false)
		_resolve()

func _resolve() -> void:
	var bypass: bool = Keeper.get_value("paleolith_dev_store", "gather_bypass", false)
	var threshold: float = 1.0 if bypass else _base_success_rate
	if randf() < threshold:
		_grant_yield()
	else:
		gather_failed.emit(_active_location)
		_log("_resolve(): fail at %s" % _active_location)

func _grant_yield() -> void:
	var yield_key: String = "flint" if _active_location == "riverbank" else "tinder"
	var cap_key: String = "flint_cap" if _active_location == "riverbank" else "tinder_cap"
	var current: int = Keeper.get_value("paleolith_store", yield_key, 0)
	var cap: int = Firm.get_value("paleolith_ledger", cap_key)
	if current >= cap:
		# lens should prevent reaching here via UI gates, but daemon is authoritative
		gather_failed.emit(_active_location)
		_log("_grant_yield(): %s already at cap (%d)" % [yield_key, cap])
		return
	Keeper.set_value("paleolith_store", yield_key, current + 1)
	gather_succeeded.emit(_active_location, current + 1)
	_log("_grant_yield(): +1 %s (%d/%d)" % [yield_key, current + 1, cap])

@warning_ignore("unused_signal")
signal gather_succeeded(location: String, new_count: int)
@warning_ignore("unused_signal")
signal gather_failed(location: String)