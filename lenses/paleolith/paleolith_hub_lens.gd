class_name PaleolithHubLens
extends Lens

const CONTEXT_KEY = "paleolith_hub"

enum HubState {
	HUB,
	GATHERING,
	GATHER_ANIMATING,
	GATHER_RESULT,
	FIRE_ATTEMPT,
	FIRE_RESULT,
	DEITY_REVEAL,
}

var state: HubState = HubState.HUB
var _pending_deity: Dictionary = {}

var _medium: PaleolithMedium = null
var _tick_daemon: PaleolithTickDaemon = null
var _gather_daemon: PaleolithGatherDaemon = null
var _fire_daemon: PaleolithFireDaemon = null
var _deity_daemon: PaleolithDeityDaemon = null

func set_medium(medium: PaleolithMedium) -> void:
	_medium = medium

func set_tick_daemon(daemon: PaleolithTickDaemon) -> void:
	_tick_daemon = daemon

func set_gather_daemon(daemon: PaleolithGatherDaemon) -> void:
	_gather_daemon = daemon

func set_fire_daemon(daemon: PaleolithFireDaemon) -> void:
	_fire_daemon = daemon

func set_deity_daemon(daemon: PaleolithDeityDaemon) -> void:
	_deity_daemon = daemon

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	state = HubState.HUB
	_request_compose()

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		HubState.HUB:
			_handle_hub(text.strip_edges().to_lower())
		HubState.GATHERING, HubState.FIRE_ATTEMPT, HubState.GATHER_ANIMATING:
			pass
		HubState.GATHER_RESULT, HubState.FIRE_RESULT:
			_handle_continue()
		HubState.DEITY_REVEAL:
			_pending_deity = {}
			state = HubState.HUB
			_request_compose()

func _handle_hub(action: String) -> void:
	var flint: int = Keeper.get_value("paleolith_store", "flint", 0)
	var tinder: int = Keeper.get_value("paleolith_store", "tinder", 0)
	var flint_cap: int = Firm.get_value("paleolith_ledger", "flint_cap")
	var tinder_cap: int = Firm.get_value("paleolith_ledger", "tinder_cap")
	var has_fire: bool = Keeper.get_value("paleolith_store", "has_fire", false)
	var revealed: Array = Keeper.get_value("paleolith_store", "revealed_deities", [])
	match action:
		"r":
			if flint >= flint_cap: return
			state = HubState.GATHERING
			_medium.compose("paleolith_gathering_start_riverbank", {})
			_gather_daemon.start_gather("riverbank")
		"s":
			if tinder >= tinder_cap: return
			state = HubState.GATHERING
			_medium.compose("paleolith_gathering_start_scrubland", {})
			_gather_daemon.start_gather("scrubland")
		"f":
			if has_fire or flint <= 0 or tinder <= 0: return
			state = HubState.FIRE_ATTEMPT
			_medium.compose("paleolith_fire_attempt", {})
			_fire_daemon.start_fire()
		"p":
			if not has_fire or revealed.is_empty(): return
			Mount.mount_lens("paleolith_pocket_lens")
			Scope.transition.call_deferred("paleolith_pocket")
		"b":
			Mount.unmount(self)
			Scope.transition("project_start")

func _handle_continue() -> void:
	_medium.hide_overlay()
	if not _pending_deity.is_empty():
		state = HubState.DEITY_REVEAL
		_medium.compose("paleolith_deity_reveal", {
			"name": _pending_deity.get("name", ""),
			"flavor": _pending_deity.get("flavor", ""),
		})
	else:
		state = HubState.HUB
		_request_compose()

func _on_gather_succeeded(location: String, new_count: int) -> void:
	var is_flint: bool = location == "riverbank"
	var key: String = "paleolith_gather_success_flint" if is_flint else "paleolith_gather_success_tinder"
	var cap: int = Firm.get_value("paleolith_ledger", "flint_cap" if is_flint else "tinder_cap")
	_medium.compose(key, {"count": new_count, "cap": cap})
	if is_flint:
		state = HubState.GATHER_ANIMATING
		var frames: Array = Firm.get_value("paleolith_asset_ledger", "flint_animation_frames", [])
		_medium.show_animated_overlay(frames)
	else:
		state = HubState.GATHER_RESULT

func _on_gather_failed(location: String) -> void:
	state = HubState.GATHER_RESULT
	var key: String = "paleolith_gather_fail_flint" if location == "riverbank" else "paleolith_gather_fail_tinder"
	_medium.compose(key, {})

func _on_fire_succeeded() -> void:
	state = HubState.FIRE_RESULT
	_medium.compose("paleolith_fire_success", {})

func _on_fire_failed() -> void:
	state = HubState.FIRE_RESULT
	_medium.compose("paleolith_fire_fail", {})

func _on_deity_revealed(deity: Dictionary) -> void:
	_pending_deity = deity

func _on_animation_complete() -> void:
	if state != HubState.GATHER_ANIMATING: return
	state = HubState.GATHER_RESULT

func _request_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_request_compose"): return
	if Guard.is_null_or_empty(_tick_daemon, name + ":_request_compose"): return
	var tick: Dictionary = _tick_daemon.build_tick_payload()
	var flint: int = Keeper.get_value("paleolith_store", "flint", 0)
	var tinder: int = Keeper.get_value("paleolith_store", "tinder", 0)
	var flint_cap: int = Firm.get_value("paleolith_ledger", "flint_cap")
	var tinder_cap: int = Firm.get_value("paleolith_ledger", "tinder_cap")
	_medium.compose("paleolith_hub", {
		"day":        tick["day"],
		"time_label": tick["time_label"],
		"weather":    tick["weather"],
		"temp_grade": tick["temp_grade"],
		"flint":      flint,
		"flint_cap":  flint_cap,
		"tinder":     tinder,
		"tinder_cap": tinder_cap,
		"options":    _build_options(flint, tinder, flint_cap, tinder_cap),
	})

func _build_options(flint: int, tinder: int, flint_cap: int, tinder_cap: int) -> String:
	var has_fire: bool = Keeper.get_value("paleolith_store", "has_fire", false)
	var revealed: Array = Keeper.get_value("paleolith_store", "revealed_deities", [])
	var lines: Array = []
	if flint < flint_cap:
		lines.append("[R]iverbank")
	if tinder < tinder_cap:
		lines.append("[S]crubland")
	if not has_fire and flint > 0 and tinder > 0:
		lines.append("[F]ire")
	if has_fire and not revealed.is_empty():
		lines.append("[P]ocket")
	lines.append("[B]ack")
	return "\n".join(lines)
