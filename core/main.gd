extends Node

var _live_nodes: Dictionary = {} # uid -> instance
var _under: Node = null

func _ready() -> void:
	_under = Node.new()
	_under.name = "under"
	add_child(_under)
	Mount.register_main(self)
	var uid = Firm.get_value("uid_ledger", "project_start_lens")
	if not Screener.verify_uid(uid, "project_start_lens", "Main._ready()"): return
	var instance = start_geist(uid)
	if instance == null: return
	Mount.register(instance, uid)

func start_geist(uid: String) -> Geist:
	var instance = _create_sceneless_node(uid)
	if instance == null: return null
	if not _is_correct_node_type(instance, Geist, "Main.start_geist()"):
		instance.queue_free()
		return null
	_complete_boot(instance, uid, "geist_init", _under)
	return instance

func start_daemon(uid: String) -> Daemon:
	var instance = _create_sceneless_node(uid)
	if instance == null: return null
	if not _is_correct_node_type(instance, Daemon, "[Main] start_daemon()"):
		instance.queue_free()
		return null
	_complete_boot(instance, uid, "daemon_init", _under)
	return instance

func start_channel(uid: String) -> Channel:
	var scene: PackedScene = load(uid)
	if Guard.is_null_or_empty(scene, "[Main] start_channel()"): return null
	var instance: Node = scene.instantiate()
	if not _is_correct_node_type(instance, Channel, "[Main] start_channel()"):
		instance.queue_free()
		return null
	_complete_boot(instance, uid, "channel_init", self)
	return instance

func dismiss_node(uid: String) -> void:
	if not _live_nodes.has(uid):
		push_error("Main.dismiss_node(uid: %s): no live node found." % uid)
		return
	var instance = _live_nodes[uid]
	_call_shutdown(instance)
	print("Main.dismiss_node(): %s dismissed." % instance.name)
	instance.queue_free()
	_live_nodes.erase(uid)

func _create_sceneless_node(uid: String) -> Node:
	var script: GDScript = load(uid)
	if script == null: return null
	var instance: Node = Node.new()
	instance.set_script(script)
	instance.name = script.resource_path.get_file().get_basename()
	return instance

func _complete_boot(instance: Node, uid: String, init_method: String, parent: Node) -> void:
	parent.add_child(instance)
	instance.call(init_method)
	_live_nodes[uid] = instance
	print("Main.%s(uid: %s): %s started." % [init_method, uid, instance.name])

func _call_shutdown(node: Node) -> void:
	if node is Daemon:
		node.daemon_shutdown()
	elif node is Geist:
		node.geist_shutdown()
	elif node is Channel:
		node.channel_shutdown()
	else:
		push_error("Main._call_shutdown(): unrecognized node type '%s'" % node.name)

func _is_correct_node_type(node: Node, correct_node_type: Variant, context: String) -> bool:
	if node == null:
		push_error("[%s]: node is null" % context)
		return false
	if not is_instance_of(node, correct_node_type):
		push_error("[%s]: node '%s' is not a %s." % [context, node.name, correct_node_type])
		return false
	return true
