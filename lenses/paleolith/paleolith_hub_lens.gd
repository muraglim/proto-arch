class_name PaleolithHubLens
extends Lens

const CONTEXT_KEY = "paleolith_hub"

# — state —

enum HubState {
	HUB,
	SITE_SELECTION,
	GATHERING,
	GATHER_ANIMATING,
	GATHER_RESULT,
	SHELTER_TRIP,
	SHELTER_RESULT,
	FIRE_ATTEMPT,
	FIRE_RESULT,
	DEITY_REVEAL,
}

var state: HubState = HubState.HUB
var _pending_deity: Dictionary = {}

# — deps —

var _medium: PaleolithMedium = null
var _tick_daemon: PaleolithTickDaemon = null
var _gather_daemon: PaleolithGatherDaemon = null
var _fire_daemon: PaleolithFireDaemon = null
var _deity_daemon: PaleolithDeityDaemon = null
var _shelter_daemon: PaleolithShelterDaemon = null

# — wiring —

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

func set_shelter_daemon(daemon: PaleolithShelterDaemon) -> void:
	_shelter_daemon = daemon

# — lifecycle —

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

@warning_ignore("unused_parameter")
func geist_resume(hint: Variant = "") -> void:
	var site: String = Keeper.get_value("paleolith_store", "shelter_location", "")
	if site.is_empty():
		state = HubState.SITE_SELECTION
		_medium.compose("paleolith_site_selection", {})
		return
	state = HubState.HUB
	_request_compose()

# — input —

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		HubState.HUB:
			_handle_hub(text.strip_edges().to_lower())
		HubState.SITE_SELECTION:
			_handle_site_selection(text.strip_edges().to_lower())
		HubState.GATHERING, HubState.FIRE_ATTEMPT, HubState.GATHER_ANIMATING:
			pass
		HubState.GATHER_RESULT, HubState.FIRE_RESULT, HubState.SHELTER_TRIP, HubState.SHELTER_RESULT:
			_handle_continue()
		HubState.DEITY_REVEAL:
			_pending_deity = {}
			state = HubState.HUB
			_request_compose()

func _handle_site_selection(action: String) -> void:
	match action:
		"1":
			_shelter_daemon.select_site("exposed_ridge")
			state = HubState.HUB
			_request_compose()
		"2":
			_shelter_daemon.select_site("sheltered_hollow")
			state = HubState.HUB
			_request_compose()

func _handle_hub(action: String) -> void:
	var flint: int = Keeper.get_value("paleolith_store", "flint", 0)
	var tinder: int = Keeper.get_value("paleolith_store", "tinder", 0)
	var flint_cap: int = Firm.get_value("paleolith_resource_ledger", "flint").get("cap", 0)
	var tinder_cap: int = Firm.get_value("paleolith_resource_ledger", "tinder").get("cap", 0)
	var has_fire: bool = Keeper.get_value("paleolith_store", "has_fire", false)
	var revealed: Array = Keeper.get_value("paleolith_store", "revealed_deities", [])
	var shelter_exists: bool = Keeper.get_value("paleolith_store", "shelter_exists", false)
	var stockpile: int = Keeper.get_value("paleolith_store", "shelter_stockpile", 0)
	var harvest_count: int = Firm.get_value("paleolith_ledger", "shelter_harvest_count")
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
		"a":
			if stockpile >= harvest_count: return
			state = HubState.SHELTER_TRIP
			var result: Dictionary = _shelter_daemon.do_harvest_trip()
			var new_stockpile: int = Keeper.get_value("paleolith_store", "shelter_stockpile", 0)
			var key: String = "paleolith_shelter_trip_lost" if result["lost"] else "paleolith_shelter_trip_clear"
			_medium.compose(key, {"stockpile": new_stockpile, "harvest_count": harvest_count})
		"c":
			if stockpile < harvest_count or shelter_exists: return
			_shelter_daemon.attempt_build()
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

# — signal handlers —

func _on_shelter_built(quality: float) -> void:
	state = HubState.SHELTER_RESULT
	_medium.compose("paleolith_shelter_built", {"quality_label": _get_quality_label(quality)})

func _on_shelter_degraded(_quality: float) -> void:
	pass

func _on_shelter_destroyed() -> void:
	if state == HubState.HUB:
		state = HubState.SHELTER_RESULT
		_medium.compose("paleolith_shelter_destroyed", {})

func _on_gather_succeeded(_location: String, resource: String, new_count: int) -> void:
	var cap: int = Firm.get_value("paleolith_resource_ledger", resource).get("cap", 0)
	_medium.compose("paleolith_gather_success_%s" % resource, {"count": new_count, "cap": cap})
	if resource == "flint":
		state = HubState.GATHER_ANIMATING
		var frames: Array = Firm.get_value("paleolith_asset_ledger", "flint_animation_frames", [])
		_medium.show_animated_overlay(frames)
	else:
		state = HubState.GATHER_RESULT

func _on_gather_failed(_location: String, resource: String) -> void:
	state = HubState.GATHER_RESULT
	_medium.compose("paleolith_gather_fail_%s" % resource, {})

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

# — compose —

func _request_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_request_compose"): return
	if Guard.is_null_or_empty(_tick_daemon, name + ":_request_compose"): return
	var tick: Dictionary = _tick_daemon.build_tick_payload()
	var flint: int = Keeper.get_value("paleolith_store", "flint", 0)
	var tinder: int = Keeper.get_value("paleolith_store", "tinder", 0)
	var flint_cap: int = Firm.get_value("paleolith_resource_ledger", "flint").get("cap", 0)
	var tinder_cap: int = Firm.get_value("paleolith_resource_ledger", "tinder").get("cap", 0)
	var stockpile: int = Keeper.get_value("paleolith_store", "shelter_stockpile", 0)
	var harvest_count: int = Firm.get_value("paleolith_ledger", "shelter_harvest_count")
	_medium.compose("paleolith_hub", {
		"day":           tick["day"],
		"time_label":    tick["time_label"],
		"weather":       tick["weather"],
		"flint":         flint,
		"flint_cap":     flint_cap,
		"tinder":        tinder,
		"tinder_cap":    tinder_cap,
		"stockpile":     stockpile,
		"harvest_count": harvest_count,
		"shelter_status": _get_shelter_status(),
		"options":       _build_options(flint, tinder, flint_cap, tinder_cap),
	})

func _build_options(flint: int, tinder: int, flint_cap: int, tinder_cap: int) -> String:
	var has_fire: bool = Keeper.get_value("paleolith_store", "has_fire", false)
	var revealed: Array = Keeper.get_value("paleolith_store", "revealed_deities", [])
	var shelter_exists: bool = Keeper.get_value("paleolith_store", "shelter_exists", false)
	var stockpile: int = Keeper.get_value("paleolith_store", "shelter_stockpile", 0)
	var harvest_count: int = Firm.get_value("paleolith_ledger", "shelter_harvest_count")
	var lines: Array = []
	if stockpile < harvest_count:
		lines.append("[A]cacia thicket")
	if flint < flint_cap:
		lines.append("[R]iverbank")
	if tinder < tinder_cap:
		lines.append("[S]crubland")
	if stockpile >= harvest_count and not shelter_exists:
		lines.append("[C]onstruct shelter")
	if not has_fire and flint > 0 and tinder > 0:
		lines.append("[F]ire")
	if has_fire and not revealed.is_empty():
		lines.append("[P]ocket")
	lines.append("[B]ack")
	return "\n".join(lines)

func _get_shelter_status() -> String:
	if Keeper.get_value("paleolith_store", "shelter_exists", false):
		var quality: float = Keeper.get_value("paleolith_store", "shelter_quality", 0.0)
		return "Shelter: %s (%d%%)" % [_get_quality_label(quality), int(quality * 100)]
	if not Keeper.get_value("paleolith_store", "shelter_location", "").is_empty():
		return "No shelter"
	return ""

func _get_quality_label(quality: float) -> String:
	var grades: Array = Firm.get_value("paleolith_ledger", "shelter_quality_grades")
	for grade in grades:
		if quality < grade["max"]:
			return grade["label"]
	return "Unknown"
