# is_channel() and is_daemon() are type validators: return true = valid, false = error.
# this inverts the sentinel pattern used elsewhere in Guard (true = error, stop).
# inversion is intentional for callsite legibility — if not Guard.is_channel() reads naturally.
# revisit if the guard family grows and these remain the only outliers.

extends Node

func is_front_empty_after_boot(front_container: Node, is_booted: bool, context: String) -> bool:
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
		push_error("CRITICAL [%s]: '%s' does not exist as a registered resource." % [context, scene])
		return true
	return false

func is_channel(node: Node, context: String) -> bool:
	if not node is Channel:
		push_error("CRITICAL [%s]: node '%s' is not a Channel." % [context, node.name])
		return false
	return true

func is_daemon(node: Node, context: String) -> bool:
	if node == null:
		push_error("CRITICAL [%s]: node is null" % context)
		return false
	if not node is Daemon:
		push_error("CRITICAL [%s]: node '%s' is not a Daemon" % [context, node.name])
		return false
	return true

func is_back_valid(result: bool, context: String) -> bool:
	if not result:
		push_error("CRITICAL: [%s]: target channel is not in back container." % context)
		return false
	return true
