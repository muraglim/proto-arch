class_name PaleolithGatherDaemon
extends Daemon

var _elapsed: float = 0.0
var _active_duration: float = 0.0
var _active_resource: String = ""
var _base_success_rate: float = 0.0

func daemon_init() -> void:
	set_process(false)
	_log("daemon_init(): online.")

func daemon_shutdown() -> void:
	set_process(false)
	_log("daemon_shutdown(): offline.")

func start_gather(resource_key: String) -> void:
	var resource: Dictionary = Firm.get_value("paleolith_resource_ledger", resource_key)
	if Guard.is_null_or_empty(resource, name + ":start_gather(%s)" % resource_key): return
	_active_resource = resource_key
	_active_duration = resource.get("gather_duration", 2.0)
	_base_success_rate = resource.get("base_success_rate", 0.6)
	_elapsed = 0.0
	set_process(true)
	_log("start_gather(): %s (%.1fs)" % [resource_key, _active_duration])

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
		gather_failed.emit(_active_resource)
		_log("_resolve(): fail — %s" % _active_resource)

func _grant_yield() -> void:
	var resource: Dictionary = Firm.get_value("paleolith_resource_ledger", _active_resource)
	var store_key: String = resource.get("store_key", _active_resource)
	var cap: int = resource.get("cap", 0)
	var current: int = Keeper.get_value("paleolith_store", store_key, 0)
	if current >= cap:
		gather_failed.emit(_active_resource)
		_log("_grant_yield(): %s at cap (%d)" % [store_key, cap])
		return
	Keeper.set_value("paleolith_store", store_key, current + 1)
	gather_succeeded.emit(_active_resource, current + 1)
	_log("_grant_yield(): +1 %s (%d/%d)" % [store_key, current + 1, cap])

@warning_ignore("unused_signal")
signal gather_succeeded(resource: String, new_count: int)
@warning_ignore("unused_signal")
signal gather_failed(resource: String)
