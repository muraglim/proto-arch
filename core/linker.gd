extends Node

# Linker — dependency orchestration autoload.
# Lens calls Linker.register(self) in geist_init().
# Linker reads dep_ledger, boots deps in order via Main, executes wiring declarations.
# Main calls Linker.register_main() in _ready() before any Lens boots.
#
# Wire case types:
#   "signal" — connects a signal on source to a method on target
#   "call"   — calls a method on source, passing target as argument
#   "assign" — sets a named property on target to the source instance
#
# Explicit "source" field required only when wire caller is not the current dep.
# Daemons do not register sub-daemons in this architecture.

var _main: Node = null

# _lens_registry: lens_key -> { role: {"node": Node, "uid": String} }
# only Lens instances register top-level entries (register()); _boot_dep()
# only ever writes into an entry a Lens already created.
# populated on register(), cleared on evict()
var _lens_registry: Dictionary = {}

func register_main(main: Node) -> void:
	_main = main
	print("Linker.register_main(Main): wired.")

func register(lens: Lens) -> void:
	var lens_key = lens.name.to_lower()
	var deps = Firm.get_value("dep_ledger", lens_key)
	if deps == null:
		print("Linker.register(%s): no dep entry found, nothing to do." % lens_key)
		return
	_lens_registry[lens_key] = {"self": {"node": lens, "uid": ""}}
	print("Linker.register(%s): registry initialized." % lens_key)
	var sorted = deps.duplicate()
	sorted.sort_custom(func(a, b): return a["order"] < b["order"])
	for dep in sorted:
		_boot_dep(lens_key, dep)
	if Scope.active_context == lens.CONTEXT_KEY:
		lens.geist_resume()

# evict() has no current caller — Lens/Daemon/Medium instances are cheap
# and stay resident for the session in the current single-prototype scope.
# reserved for prototype-to-prototype memory pruning once the carousel
# has multiple concurrent contexts worth tearing down.
func evict(lens: Lens) -> void:
	var lens_key = lens.name.to_lower()
	if not _lens_registry.has(lens_key):
		print("Linker.evict(%s): no registry found, nothing to do." % lens_key)
		return
	var registry = _lens_registry[lens_key]
	for role in registry:
		var entry = registry[role]
		if entry == null or entry.get("node") == null: continue
		_main.dismiss_node(entry["uid"])
		print("Linker.evict(%s, role: %s): %s evicted." % [lens_key, role, entry["node"].name])
	_lens_registry.erase(lens_key)
	print("Linker.evict(%s): registry cleared." % lens_key)

# — boot —

func _boot_dep(lens_key: String, dep: Dictionary) -> void:
	var uid_key = dep.get("uid_key", "")
	var role = dep.get("role", "")
	var type = dep.get("type", "")
	if Guard.is_null_or_empty(uid_key, "Linker._boot_dep(%s)" % lens_key): return
	if Guard.is_null_or_empty(role, "Linker._boot_dep(%s)" % lens_key): return
	if Guard.is_null_or_empty(type, "Linker._boot_dep(%s)" % lens_key): return	
	var uid = Firm.get_value("uid_ledger", uid_key)
	if not Screener.verify_uid(uid, uid_key, "Linker._boot_dep(%s)" % uid_key): return
	var existing = _find_live_node(uid)
	if existing != null:
		_lens_registry[lens_key][role] = {"node": existing, "uid": uid}
		print("Linker._boot_dep(%s, role: %s): already live, registering existing instance." % [lens_key, role])
		_execute_wires(lens_key, dep)
		return
	var instance = _boot_via_main(uid, type)
	if instance == null: return
	Echo.log_list([uid_key, uid, lens_key, dep])
	_lens_registry[lens_key][role] = {"node": instance, "uid": uid}
	print("Linker._boot_dep(%s, role: %s): %s booted." % [lens_key, role, instance.name])
	_execute_wires(lens_key, dep)

func boot_lens(uid_key: String) -> void:
	var uid = Firm.get_value("uid_ledger", uid_key)
	if not Screener.verify_uid(uid, uid_key, "Linker.boot_lens(%s)" % uid_key): return
	var existing = _find_live_node(uid)
	if existing != null:
		print("Linker.boot_lens(%s): already live." % uid)
		return
	var instance = _main.start_geist(uid)
	if instance == null: return
	register(instance)

func _boot_via_main(uid: String, type: String) -> Node:
	match type:
		"daemon": return _main.start_daemon(uid)
		"geist": return _main.start_geist(uid)
		"channel": return _main.start_channel(uid)
		_:
			push_error("Linker._boot_via_main(): unknown type '%s'" % type)
			return null

func _find_live_node(uid: String) -> Node:
	var path = ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
	var target_name = path.get_file().get_basename()
	for lens_key in _lens_registry:
		for role in _lens_registry[lens_key]:
			var entry = _lens_registry[lens_key][role]
			if entry != null and entry.get("node") != null and entry["node"].name == target_name:
				return entry["node"]
	return null

# — wires —

func _execute_wires(lens_key: String, dep: Dictionary) -> void:
	var wires = dep.get("wires", [])
	if wires.is_empty(): return
	var role = dep.get("role", "")
	for wire in wires:
		_execute_wire(lens_key, role, wire)

func _execute_wire(lens_key: String, current_role: String, wire: Dictionary) -> void:
	var case_type = wire.get("case", "")
	var source_role = wire.get("source", current_role)
	var target_role = wire.get("target", "")
	if Guard.is_null_or_empty(case_type, "Linker._execute_wire(%s)" % lens_key): return
	if Guard.is_null_or_empty(target_role, "Linker._execute_wire(%s)" % lens_key): return
	var source = _resolve_role(lens_key, source_role)
	var target = _resolve_role(lens_key, target_role)
	if source == null:
		push_error("Linker._execute_wire(%s): could not resolve source role '%s'." % [lens_key, source_role])
		return
	if target == null:
		push_error("Linker._execute_wire(%s): could not resolve target role '%s'." % [lens_key, target_role])
		return
	match case_type:
		"signal":
			_execute_signal_wire(lens_key, source, target, wire)
		"call":
			_execute_call_wire(lens_key, source, target, wire)
		"assign":
			_execute_assign_wire(lens_key, source, target, wire)
		_:
			push_error("Linker._execute_wire(%s): unknown case type '%s'." % [lens_key, case_type])

func _execute_signal_wire(lens_key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var signal_name = wire.get("signal", "")
	var method_name = wire.get("method", "")
	if Guard.is_null_or_empty(signal_name, "Linker._execute_signal_wire(%s)" % lens_key): return
	if Guard.is_null_or_empty(method_name, "Linker._execute_signal_wire(%s)" % lens_key): return
	if not source.has_signal(signal_name):
		push_error("Linker._execute_signal_wire(%s): '%s' has no signal '%s'." % [lens_key, source.name, signal_name])
		return
	if not target.has_method(method_name):
		push_error("Linker._execute_signal_wire(%s): '%s' has no method '%s'." % [lens_key, target.name, method_name])
		return
	source.get(signal_name).connect(target.get(method_name))
	print("Linker._execute_signal_wire: %s.%s -> %s.%s" % [source.name, signal_name, target.name, method_name])

func _execute_call_wire(lens_key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var method_name = wire.get("method", "")
	if Guard.is_null_or_empty(method_name, "Linker._execute_call_wire(%s)" % lens_key): return
	if not source.has_method(method_name):
		push_error("Linker._execute_call_wire(%s): '%s' has no method '%s'." % [lens_key, source.name, method_name])
		return
	source.call(method_name, target)
	print("Linker._execute_call_wire: %s.%s(%s)" % [source.name, method_name, target.name])

func _execute_assign_wire(lens_key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var property = wire.get("property", "")
	if Guard.is_unresolved(property, "Linker._execute_assign_wire(%s)" % lens_key): return
	if not property in target:
		push_error("Linker._execute_assign_wire(%s): '%s' has no property '%s'." % [lens_key, target.name, property])
		return
	target.set(property, source)
	print("Linker._execute_assign_wire: %s -> %s.%s" % [source.name, target.name, property])

# — resolution —

func _resolve_role(lens_key: String, role: String) -> Node:
	if not _lens_registry.has(lens_key): return null
	var entry = _lens_registry[lens_key].get(role, null)
	if entry == null: return null
	return entry.get("node", null)

func _find_daemon_by_role(lens_key: String, role: String) -> Daemon:
	if not _lens_registry.has(lens_key): return null
	var entry = _lens_registry[lens_key].get(role, null)
	if entry == null: return null
	return entry.get("node", null) as Daemon
