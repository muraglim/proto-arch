class_name PaleolithGatherLens
extends Lens

const CONTEXT_KEY = "paleolith_gather"

# — state —

enum GatherState { IDLE, GATHERING, GATHER_ANIMATING, GATHER_RESULT }

var state: GatherState = GatherState.IDLE
var _location: String = ""
var _material_resource: String = ""
var _food_resource: String = ""

# — deps —

var _medium: PaleolithMedium = null
var _gather_daemon: PaleolithGatherDaemon = null

# — wiring —

func set_medium(medium: PaleolithMedium) -> void:
	_medium = medium

func set_gather_daemon(daemon: PaleolithGatherDaemon) -> void:
	_gather_daemon = daemon

# — lifecycle —

func geist_init() -> void:
	Scope.register(self)

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

func geist_resume(hint: Variant = "") -> void:
	_location = hint if hint is String and not (hint as String).is_empty() else ""
	if Guard.is_null_or_empty(_location, name + ":geist_resume"): return
	var locations: Dictionary = Firm.get_value("paleolith_location_ledger", "locations")
	var loc: Dictionary = locations.get(_location, {})
	_material_resource = loc.get("material_node", "")
	_food_resource = loc.get("food_node", "")
	state = GatherState.IDLE
	_request_compose()

# — input —

func _on_input(text: String) -> void:
	if Scope.active_context != CONTEXT_KEY: return
	match state:
		GatherState.IDLE:
			_handle_idle(text.strip_edges().to_lower())
		GatherState.GATHERING, GatherState.GATHER_ANIMATING:
			pass
		GatherState.GATHER_RESULT:
			_medium.hide_overlay()
			state = GatherState.IDLE
			_request_compose()

func _handle_idle(action: String) -> void:
	match action:
		"m":
			var resource: Dictionary = Firm.get_value("paleolith_resource_ledger", _material_resource)
			var current: int = Keeper.get_value("paleolith_store", resource.get("store_key", _material_resource), 0)
			if current >= resource.get("cap", 0): return
			state = GatherState.GATHERING
			_medium.compose("paleolith_gather_start_%s" % _material_resource, {})
			_gather_daemon.start_gather(_material_resource)
		"f":
			var resource: Dictionary = Firm.get_value("paleolith_resource_ledger", _food_resource)
			var current: int = Keeper.get_value("paleolith_store", resource.get("store_key", _food_resource), 0)
			if current >= resource.get("cap", 0): return
			state = GatherState.GATHERING
			_medium.compose("paleolith_gather_start_%s" % _food_resource, {})
			_gather_daemon.start_gather(_food_resource)
		"b":
			Scope.transition("paleolith_hub")

# — signal handlers —

func _on_gather_succeeded(resource: String, new_count: int) -> void:
	var resource_data: Dictionary = Firm.get_value("paleolith_resource_ledger", resource)
	var cap: int = resource_data.get("cap", 0)
	_medium.compose("paleolith_gather_success_%s" % resource, {"count": new_count, "cap": cap})
	if resource == "flint":
		state = GatherState.GATHER_ANIMATING
		var frames: Array = Firm.get_value("paleolith_asset_ledger", "flint_animation_frames", [])
		_medium.show_animated_overlay(frames)
	else:
		state = GatherState.GATHER_RESULT

func _on_gather_failed(resource: String) -> void:
	state = GatherState.GATHER_RESULT
	_medium.compose("paleolith_gather_fail_%s" % resource, {})

func _on_animation_complete() -> void:
	if state != GatherState.GATHER_ANIMATING: return
	state = GatherState.GATHER_RESULT

# — compose —

func _request_compose() -> void:
	if Guard.is_null_or_empty(_medium, name + ":_request_compose"): return
	var locations: Dictionary = Firm.get_value("paleolith_location_ledger", "locations")
	var loc: Dictionary = locations.get(_location, {})
	var mat_data: Dictionary = Firm.get_value("paleolith_resource_ledger", _material_resource)
	var food_data: Dictionary = Firm.get_value("paleolith_resource_ledger", _food_resource)
	var mat_store: String = mat_data.get("store_key", _material_resource)
	var food_store: String = food_data.get("store_key", _food_resource)
	var mat_count: int = Keeper.get_value("paleolith_store", mat_store, 0)
	var food_count: int = Keeper.get_value("paleolith_store", food_store, 0)
	var mat_cap: int = mat_data.get("cap", 0)
	var food_cap: int = food_data.get("cap", 0)
	_medium.compose("paleolith_gather_hub", {
		"location_label":  loc.get("label", _location),
		"material_label":  mat_data.get("label", _material_resource),
		"food_label":      food_data.get("label", _food_resource),
		"material_count":  mat_count,
		"material_cap":    mat_cap,
		"food_count":      food_count,
		"food_cap":        food_cap,
		"options":         _build_options(mat_data.get("label", _material_resource), mat_count, mat_cap,
										  food_data.get("label", _food_resource), food_count, food_cap),
	})

func _build_options(mat_label: String, mat_count: int, mat_cap: int,
		food_label: String, food_count: int, food_cap: int) -> String:
	var lines: Array = []
	if mat_count < mat_cap:
		lines.append("[M]aterial - %s" % mat_label)
	if food_count < food_cap:
		lines.append("[F]ood - %s" % food_label)
	lines.append("[B]ack")
	return "\n".join(lines)
