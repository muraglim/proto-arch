extends Node

var _live_nodes: Dictionary = {} # dest -> instance

func _ready() -> void:
	Linker.register_main(self)
	var entry = Firm.get_value("_nav_dest_ledger", "project_start_lens")
	if Guard.is_invalid_uid(entry, "[Main] _ready()"): return
	var boot_target = entry["uid"]
	if Guard.is_unresolved(boot_target, "[Main] _ready()"): return
	var instance = start_geist(boot_target)
	if instance == null: return
	Linker.register(instance)

func start_geist(dest: String) -> Geist:
	var script: GDScript = load(dest)
	if Guard.is_unresolved(script, "[Main] start_geist()"): return null
	var instance: Node = Node.new()
	instance.set_script(script)
	instance.name = script.resource_path.get_file().get_basename()
	if not _is_correct_node_type(instance, Geist, "[Main] start_geist()"):
		instance.queue_free()
		return null
	instance.geist_init()
	_live_nodes[dest] = instance
	print("[Main] start_geist(dest: %s): %s started." % [dest, instance.name])
	return instance

func start_daemon(dest: String) -> Daemon:
	var script: GDScript = load(dest)
	if Guard.is_unresolved(script, "[Main] start_daemon()"): return null
	var instance: Node = Node.new()
	instance.set_script(script)
	instance.name = script.resource_path.get_file().get_basename()
	if not _is_correct_node_type(instance, Daemon, "[Main] start_daemon()"):
		instance.queue_free()
		return null
	instance.daemon_init()
	_live_nodes[dest] = instance
	print("[Main] start_daemon(dest: %s): %s started." % [dest, instance.name])
	return instance

func start_channel(dest: String) -> Channel:
	var scene: PackedScene = load(dest)
	if Guard.is_unresolved(scene, "[Main] start_channel()"): return null
	var instance: Node = scene.instantiate()
	if not _is_correct_node_type(instance, Channel, "[Main] start_channel()"):
		instance.queue_free()
		return null
	add_child(instance)
	instance.channel_dest = dest
	instance.channel_init()
	_live_nodes[dest] = instance
	print("[Main] start_channel(dest: %s): %s started." % [dest, instance.name])
	return instance

func dismiss_node(dest: String) -> void:
	if not _live_nodes.has(dest):
		push_error("[Main] dismiss_node(dest: %s): no live node found." % dest)
		return
	var instance = _live_nodes[dest]
	_call_shutdown(instance)
	print("[Main] dismiss_node(): %s dismissed." % instance.name)
	instance.queue_free()
	_live_nodes.erase(dest)

func _call_shutdown(node: Node) -> void:
	if node is Daemon:
		node.daemon_shutdown()
	elif node is Geist:
		node.geist_shutdown()
	elif node is Channel:
		node.channel_shutdown()
	else:
		push_error("[Main] _call_shutdown(): unrecognized node type '%s'" % node.name)

func _is_correct_node_type(node: Node, correct_node_type: Variant, context: String) -> bool:
	if node == null:
		push_error("CRITICAL [%s]: node is null" % context)
		return false
	if not is_instance_of(node, correct_node_type):
		push_error("CRITICAL [%s]: node '%s' is not a %s." % [context, node.name, correct_node_type])
		return false
	return true
