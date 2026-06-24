class_name PaleolithFireDaemon
extends Daemon

var _elapsed: float = 0.0
var _duration: float = 0.0
var _base_success_rate: float = 0.0

func daemon_init() -> void:
	set_process(false)
	_duration = Firm.get_value("paleolith_ledger", "fire_duration")
	_base_success_rate = Firm.get_value("paleolith_ledger", "fire_base_success_rate")
	_log("daemon_init(): online.")

func daemon_shutdown() -> void:
	set_process(false)
	_log("daemon_shutdown(): offline.")

func start_fire() -> void:
	if Keeper.get_value("paleolith_store", "has_fire", false):
		_log("start_fire(): fire already lit.")
		return
	var tinder: int = Keeper.get_value("paleolith_store", "tinder", 0)
	Keeper.set_value("paleolith_store", "tinder", tinder - 1)
	_elapsed = 0.0
	set_process(true)
	_log("start_fire(): attempting. tinder remaining: %d" % (tinder - 1))

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		set_process(false)
		_resolve()

func _resolve() -> void:
	var bypass: bool = Keeper.get_value("paleolith_dev_store", "fire_bypass", false)
	var threshold: float = 1.0 if bypass else _base_success_rate
	if randf() < threshold:
		Keeper.set_value("paleolith_store", "has_fire", true)
		fire_succeeded.emit()
		_log("_resolve(): fire lit.")
	else:
		fire_failed.emit()
		_log("_resolve(): fire failed.")

@warning_ignore("unused_signal")
signal fire_succeeded
@warning_ignore("unused_signal")
signal fire_failed