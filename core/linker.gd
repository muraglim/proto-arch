extends Node

# Linker — dependency orchestration autoload.
# Replaces the channel-as-mediator pattern for Channel/Daemon boot and wiring.
# Channels call Linker.register(self) in channel_init().
# Linker reads _dep_ledger, boots daemons in order, executes wiring declarations.
# Main calls Linker.register_main() in _ready() before any channel boots.
#
# Wire case types:
#   "signal" — connects a signal on source to a method on target
#   "call"   — calls a method on source, passing target as argument
#   "assign" — sets a named property on target to the source instance
#
# "channel" is a reserved role, always resolving to the registering Channel.
# Explicit "source" field required only when wire caller is not the current dep.
# Daemons do not register sub-daemons in this architecture.

var _main: Node = null
var _front: Node = null
var _back: Node = null
var _under: Node = null

# _registries: channel_key -> { role: node }
# populated on register(), cleared on evict()
var _registries: Dictionary = {}

func register_main(main: Node, front: Node, back: Node, under: Node) -> void:
	_main = main
	_front = front
	_back = back
	_under = under
	print("[Linker] register_main(): main wired.")

func register(channel: Channel) -> void:
	var key = channel.name.to_lower()
	var deps = Firm.get_value("_dep_ledger", key)
	if deps == null:
		print("[Linker] register(%s): no dep entry found, nothing to do." % key)
		return
	_registries[key] = {"channel": channel}
	print("[Linker] register(%s): registry initialized." % key)
	var sorted = deps.duplicate()
	sorted.sort_custom(func(a, b): return a["order"] < b["order"])
	for dep in sorted:
		_boot_dep(channel, key, dep)

func evict(channel: Channel) -> void:
	var key = channel.name.to_lower()
	if not _registries.has(key):
		print("[Linker] evict(%s): no registry found, nothing to do." % key)
		return
	var registry = _registries[key]
	for role in registry:
		if role == "channel": continue
		var node = registry[role]
		if node == null or not node is Daemon: continue
		var daemon = node as Daemon
		daemon.daemon_shutdown()
		_under.remove_child(daemon)
		daemon.queue_free()
		print("[Linker] evict(%s, role: %s): %s evicted." % [key, role, daemon.name])
	_registries.erase(key)
	print("[Linker] evict(%s): registry cleared." % key)

# — Boot —

@warning_ignore("unused_parameter")
func _boot_dep(channel: Channel, channel_key: String, dep: Dictionary) -> void:
	var dest = dep.get("dest", "")
	var role = dep.get("role", "")
	if Guard.is_unresolved(dest, "[Linker] _boot_dep(%s)" % channel_key): return
	if Guard.is_unresolved(role, "[Linker] _boot_dep(%s)" % channel_key): return
	var nav_entry = Firm.get_value("_nav_dest_ledger", dest)
	if Guard.is_invalid_uid(nav_entry, "[Linker] _boot_dep(%s, dest: %s)" % [channel_key, dest]): return
	var uid = nav_entry["uid"]
	var existing = _find_live_daemon(uid)
	if existing != null:
		_registries[channel_key][role] = existing
		print("[Linker] _boot_dep(%s, role: %s): already live, registering existing instance." % [channel_key, role])
		_execute_wires(channel_key, dep)
		return
	var instance = _instantiate_daemon(uid, channel_key)
	if instance == null: return
	_under.add_child(instance)
	instance._connect_to_main(_main)
	instance.daemon_init()
	_registries[channel_key][role] = instance
	print("[Linker] _boot_dep(%s, role: %s): %s booted." % [channel_key, role, instance.name])
	_execute_wires(channel_key, dep)

# Duplicates Main.start_daemon() instantiation logic.
# Isolated here to give a single callsite for future consolidation
# if a clean Main interface for Linker-driven boot emerges.
func _instantiate_daemon(uid: String, context: String) -> Daemon:
	var script: GDScript = load(uid)
	if Guard.is_unresolved(script, "[Linker] _instantiate_daemon(%s)" % context): return null
	var instance: Node = Node.new()
	instance.set_script(script)
	instance.name = script.resource_path.get_file().get_basename()
	if not instance is Daemon:
		push_error("CRITICAL [Linker] _instantiate_daemon(%s): '%s' is not a Daemon." % [context, uid])
		instance.queue_free()
		return null
	return instance

func _find_live_daemon(uid: String) -> Daemon:
	var path = ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
	var target_name = path.get_file().get_basename()
	for child in _under.get_children():
		var daemon = child as Daemon
		if daemon and daemon.name == target_name:
			return daemon
	return null

# — Wires —

func _execute_wires(channel_key: String, dep: Dictionary) -> void:
	var wires = dep.get("wires", [])
	if wires.is_empty(): return
	var role = dep.get("role", "")
	for wire in wires:
		_execute_wire(channel_key, role, wire)

func _execute_wire(channel_key: String, current_role: String, wire: Dictionary) -> void:
	var case_type = wire.get("case", "")
	var source_role = wire.get("source", current_role)
	var target_role = wire.get("target", "")
	if Guard.is_unresolved(case_type, "[Linker] _execute_wire(%s)" % channel_key): return
	if Guard.is_unresolved(target_role, "[Linker] _execute_wire(%s)" % channel_key): return
	var source = _resolve_role(channel_key, source_role)
	var target = _resolve_role(channel_key, target_role)
	if source == null:
		push_error("CRITICAL [Linker] _execute_wire(%s): could not resolve source role '%s'." % [channel_key, source_role])
		return
	if target == null:
		push_error("CRITICAL [Linker] _execute_wire(%s): could not resolve target role '%s'." % [channel_key, target_role])
		return
	match case_type:
		"signal":
			_execute_signal_wire(channel_key, source, target, wire)
		"call":
			_execute_call_wire(channel_key, source, target, wire)
		"assign":
			_execute_assign_wire(channel_key, source, target, wire)
		_:
			push_error("CRITICAL [Linker] _execute_wire(%s): unknown case type '%s'." % [channel_key, case_type])

func _execute_signal_wire(channel_key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var signal_name = wire.get("signal", "")
	var method_name = wire.get("method", "")
	if Guard.is_unresolved(signal_name, "[Linker] _execute_signal_wire(%s)" % channel_key): return
	if Guard.is_unresolved(method_name, "[Linker] _execute_signal_wire(%s)" % channel_key): return
	if not source.has_signal(signal_name):
		push_error("CRITICAL [Linker] _execute_signal_wire(%s): '%s' has no signal '%s'." % [channel_key, source.name, signal_name])
		return
	if not target.has_method(method_name):
		push_error("CRITICAL [Linker] _execute_signal_wire(%s): '%s' has no method '%s'." % [channel_key, target.name, method_name])
		return
	source.get(signal_name).connect(target.get(method_name))
	print("[Linker] signal: %s.%s -> %s.%s" % [source.name, signal_name, target.name, method_name])

func _execute_call_wire(channel_key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var method_name = wire.get("method", "")
	if Guard.is_unresolved(method_name, "[Linker] _execute_call_wire(%s)" % channel_key): return
	if not source.has_method(method_name):
		push_error("CRITICAL [Linker] _execute_call_wire(%s): '%s' has no method '%s'." % [channel_key, source.name, method_name])
		return
	source.call(method_name, target)
	print("[Linker] call: %s.%s(%s)" % [source.name, method_name, target.name])

func _execute_assign_wire(channel_key: String, source: Node, target: Node, wire: Dictionary) -> void:
	var property = wire.get("property", "")
	if Guard.is_unresolved(property, "[Linker] _execute_assign_wire(%s)" % channel_key): return
	if not property in target:
		push_error("CRITICAL [Linker] _execute_assign_wire(%s): '%s' has no property '%s'." % [channel_key, target.name, property])
		return
	target.set(property, source)
	print("[Linker] assign: %s -> %s.%s" % [source.name, target.name, property])

# — Resolution —

func _resolve_role(channel_key: String, role: String) -> Node:
	if not _registries.has(channel_key): return null
	return _registries[channel_key].get(role, null)

func _find_daemon_by_role(channel_key: String, role: String) -> Daemon:
	if not _registries.has(channel_key): return null
	var node = _registries[channel_key].get(role, null)
	if node == null: return null
	return node as Daemon
