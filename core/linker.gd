extends Node

# Linker — pure wire executor.
# Receives a registry slice from Mount and executes declared wiring.
# Stateless: owns no registry, no refcounts, no live-node tracking.
# Called only by Mount._mount_dep(); no external call sites.
#
# Wire case types:
#   "signal" — connects a signal on source to a method on target
#   "call"   — calls a method on source, passing target as argument
#   "assign" — sets a named property on target to the source instance
#
# Explicit "source" field required only when wire caller is not the current dep.

func execute_wires(lens_key: String, dep: Dictionary, registry: Dictionary) -> void:
	var wires = dep.get("wires", [])
	if wires.is_empty(): return
	var role = dep.get("role", "")
	for wire in wires:
		_execute_wire(lens_key, role, wire, registry)

func _execute_wire(lens_key: String, current_role: String, wire: Dictionary, registry: Dictionary) -> void:
	var case_type = wire.get("case", "")
	var source_role = wire.get("source", current_role)
	var target_role = wire.get("target", "")
	if Guard.is_null_or_empty(case_type, "Linker._execute_wire(%s)" % lens_key): return
	if Guard.is_null_or_empty(target_role, "Linker._execute_wire(%s)" % lens_key): return
	var source = _resolve_role(registry, source_role)
	var target = _resolve_role(registry, target_role)
	if source == null:
		push_error("Linker._execute_wire(%s): could not resolve source role '%s'." % [lens_key, source_role])
		return
	if target == null:
		push_error("Linker._execute_wire(%s): could not resolve target role '%s'." % [lens_key, target_role])
		return
	match case_type:
		"signal": _execute_signal_wire(lens_key, source, target, wire)
		"call":   _execute_call_wire(lens_key, source, target, wire)
		"assign": _execute_assign_wire(lens_key, source, target, wire)
		_: push_error("Linker._execute_wire(%s): unknown case type '%s'." % [lens_key, case_type])

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
	if Guard.is_null_or_empty(property, "Linker._execute_assign_wire(%s)" % lens_key): return
	if not property in target:
		push_error("Linker._execute_assign_wire(%s): '%s' has no property '%s'." % [lens_key, target.name, property])
		return
	target.set(property, source)
	print("Linker._execute_assign_wire: %s -> %s.%s" % [source.name, target.name, property])

func _resolve_role(registry: Dictionary, role: String) -> Node:
	var entry = registry.get(role, null)
	if entry == null: return null
	return entry.get("node", null)
