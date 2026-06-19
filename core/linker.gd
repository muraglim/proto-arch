extends Node

# Linker — dependency orchestration autoload.
# Lens calls Linker.register(self) in geist_init().
# Linker reads _dep_ledger, boots deps in order via Main, executes wiring declarations.
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

# _registries: key -> { role: {"node": Node, "uid": String} }
# populated on register(), cleared on evict()
var _registries: Dictionary = {}

func register_main(main: Node) -> void:
	_main = main
	print("[Linker] register_main(): main wired.")

func register(lens: Lens) -> void:
	var key = lens.name.to_lower()
	var deps = Firm.get_value("_dep_ledger", key)
	if deps == null:
		print("[Linker] register(%s): no dep entry found, nothing to do." % key)
		return
	_registries[key] = {"self": {"node": lens, "uid": ""}}
	print("[Linker] register(%s): registry initialized." % key)
	var sorted = deps.duplicate()
	sorted.sort_custom(func(a, b): return a["order"] < b["order"])
	for dep in sorted:
		_boot_dep(key, dep)
	if Scope.active_context == lens.CONTEXT_KEY:
		lens.geist_resume()

func boot_lens(dest_key: String) -> void:
	var nav_entry = Firm.get_value("_nav_dest_ledger", dest_key)
	if Guard.is_invalid_uid(nav_entry, "[Linker] boot_lens(%s)" % dest_key): return
	var uid = nav_entry["uid"]
	var existing = _find_live_node(uid)
	if existing != null:
		print("[Linker] boot_lens(%s): already live." % dest_key)
		return
	var instance = _main.start_geist(uid)
	if instance == null: return
	register(instance)

# evict() has no current caller — Lens/Daemon/Medium instances are cheap
# and stay resident for the session in the current single-prototype scope.
# Reserved for prototype-to-prototype memory pruning once the carousel
# has multiple concurrent contexts worth tearing down.
func evict(lens: Lens) -> void:
	var key = lens.name.to_lower()
	if not _registries.has(key):
		print("[Linker] evict(%s): no registry found, nothing to do." % key)
		return
	var registry = _registries[key]
	for role in registry:
		var entry = registry[role]
		if entry == null or entry.get("node") == null: continue
		_main.dismiss_node(entry["uid"])
		print("[Linker] evict(%s, role: %s): %s evicted." % [key, role, entry["node"].name])
	_registries.erase(key)
	print("[Linker] evict(%s): registry cleared." % key)

# — Boot —

func _boot_dep(key: String, dep: Dictionary) -> void:
	var dest = dep.get("dest", "")
	var role = dep.get("role", "")
	var type = dep.get("type", "")
	if Guard.is_unresolved(dest, "[Linker] _boot_dep(%s)" % key): return
	if Guard.is_unresolved(role, "[Linker] _boot_dep(%s)" % key): return
	if Guard.is_unresolved(type, "[Linker] _boot_dep(%s)" % key): return
	var nav_entry = Firm.get_value("_nav_dest_ledger", dest)
	if Guard.is_invalid_uid(nav_entry, "[Linker] _boot_dep(%s, dest: %s)" % [key, dest]): return
	var uid = nav_entry["uid"]
	var existing = _find_live_node(uid)
	if existing != null:
		_registries[key][role] = {"node": existing, "uid": uid}
		print("[Linker] _boot_dep(%s, role: %s): already live, registering existing instance." % [key, role])
		_execute_wires(key, dep)
		return
	var instance = _boot_via_main(uid, type)
	if instance == null: return
	_registries[key][role] = {"node": instance, "uid": uid}
	print("[Linker] _boot_dep(%s, role: %s): %s booted." % [key, role, instance.name])
	_execute_wires(key, dep)

func _boot_via_main(uid: String, type: String) -> Node:
	match type:
		"daemon": return _main.start_daemon(uid)
		"geist": return _main.start_geist(uid)
		"channel": return _main.start_channel(uid)
		_:
			push_error("[Linker] _boot_via_main(): unknown type '%s'" % type)
			return null

func _find_live_node(uid: String) -> Node:
	var path = ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
	var target_name = path.get_file().get_basename()
	for key in _registries:
		for role in _registries[key]:
			var entry = _registries[key][role]
			if entry != null and entry.get("node") != null and entry["node"].name == target_name:
				return entry["node"]
	return null

# — Wires —

func _execute_wires(key: String, dep: Dictionary) -> void:
	var wires = dep.get("wires", [])
	if wires.is_empty(): return
	var role = dep.get("role", "")
	for wire in wires:
		_execute_wire(key, role, wire)

func _execute_wire(key: String, current_role: String, wire: Dictionary) -> void:
	var case_type = wire.get("case", "")
	var source_role = wire.get("source", current_role)
	var target_role = wire.get("target", "")
	if Guard.is_unresolved(case_type, "[Linker] _execute_wire(%s)" % key): return
	if Guard.is_unresolved(target_role, "[Linker] _execute_wire(%s)" % key): return
	var source = _resolve_role(key, source_role)
	var target = _resolve_role(key, target_role)
	if source == null:
		push_error("CRITICAL [Linker] _execute_wire(%s): could not resolve source role '%s'." % [key, source_role])
		return
	if target == null:
		push_error("CRITICAL [Linker] _execute_wire(%s): could not resolve target role '%s'." % [key, target_role])
		return
	match case_type:
		"signal":
			_execute_signal_wire(key, source, target, wire)
		"call":
			_execute_call_wire(key, source, target, wire)
		"assign":
			_execute_assign_wire(key, source, target, wire)
		_:
			push_error("CRITICAL [Linker] _execute_wire(%s): unknown case type '%s'." % [key, case_type])

func _execute_signal_wire(key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var signal_name = wire.get("signal", "")
	var method_name = wire.get("method", "")
	if Guard.is_unresolved(signal_name, "[Linker] _execute_signal_wire(%s)" % key): return
	if Guard.is_unresolved(method_name, "[Linker] _execute_signal_wire(%s)" % key): return
	if not source.has_signal(signal_name):
		push_error("CRITICAL [Linker] _execute_signal_wire(%s): '%s' has no signal '%s'." % [key, source.name, signal_name])
		return
	if not target.has_method(method_name):
		push_error("CRITICAL [Linker] _execute_signal_wire(%s): '%s' has no method '%s'." % [key, target.name, method_name])
		return
	source.get(signal_name).connect(target.get(method_name))
	print("[Linker] signal: %s.%s -> %s.%s" % [source.name, signal_name, target.name, method_name])

func _execute_call_wire(key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var method_name = wire.get("method", "")
	if Guard.is_unresolved(method_name, "[Linker] _execute_call_wire(%s)" % key): return
	if not source.has_method(method_name):
		push_error("CRITICAL [Linker] _execute_call_wire(%s): '%s' has no method '%s'." % [key, source.name, method_name])
		return
	source.call(method_name, target)
	print("[Linker] call: %s.%s(%s)" % [source.name, method_name, target.name])

func _execute_assign_wire(key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var property = wire.get("property", "")
	if Guard.is_unresolved(property, "[Linker] _execute_assign_wire(%s)" % key): return
	if not property in target:
		push_error("CRITICAL [Linker] _execute_assign_wire(%s): '%s' has no property '%s'." % [key, target.name, property])
		return
	target.set(property, source)
	print("[Linker] assign: %s -> %s.%s" % [source.name, target.name, property])

# — Resolution —

func _resolve_role(key: String, role: String) -> Node:
	if not _registries.has(key): return null
	var entry = _registries[key].get(role, null)
	if entry == null: return null
	return entry.get("node", null)

func _find_daemon_by_role(key: String, role: String) -> Daemon:
	if not _registries.has(key): return null
	var entry = _registries[key].get(role, null)
	if entry == null: return null
	return entry.get("node", null) as Daemon
