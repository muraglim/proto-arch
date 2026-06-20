# Predicate design note:
# is_channel() and is_daemon() are *type predicates* — they return true when
# the object is of the expected type. This is the opposite of a sentinel,
# where true signals an error. Inversion is intentional: callers use them as
# positive guards, e.g. `if is_channel(node): …`.
# When adding a new container type in Main.gd, add a matching predicate here.

extends Node

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

func is_invalid_uid(entry: Variant, context: String) -> bool:
	if not entry is Dictionary or not entry.has("uid") or entry["uid"].is_empty():
		push_error("CRITICAL [%s]: nav entry is missing or has empty uid." % context)
		return true
	return false
