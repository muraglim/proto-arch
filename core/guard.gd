extends Node

func is_boot_valid(front_container: Node, is_booted: bool, context: String) -> bool:
	if front_container.get_child_count() == 0 and is_booted:
		push_error("CRITICAL [%s]: front is empty while is_booted is true." % context)
		return true 
	return false 

func is_unresolved(value: Variant, context: String) -> bool:
	if value == null or (value is String and value.is_empty()):
		push_error("CRITICAL [%s]: requested resource is unresolved (null or empty)." % context)
		return true
	return false

func is_invalid_scene(scene: String, context: String) -> bool:
	if not ResourceLoader.exists(scene):
		push_error("CRITICAL [%s]: target scene '%s' is not a valid scene resource." % [context, scene])
		return true
	return false

func is_nav_valid(dest: String, context: String) -> bool:
	if is_unresolved(dest, context): return false
	if is_invalid_scene(dest, context): return false
	return true

func is_module(node: Node, context: String) -> bool:
	if not node is Module:
		push_error("CRITICAL [%s]: node '%s' is not a Module." % [context, node.name])
		return false
	return true

func is_daemon(node: Node, context: String) -> bool:
	if not node is Daemon:
		push_error("CRITICAL [%s]: node '%s' is not a Daemon" % [context, node.name])
		return false
	return true
