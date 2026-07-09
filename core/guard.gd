## Guard — sentinel validation predicates.
## Low-level data integrity checks (type, null, UID resolution).
## Returns true on failure, callers halt execution when true.

extends Node

func is_null_or_empty(value: Variant, context: String) -> bool:
	if value == null:
		push_error("[Guard] %s: requested resource is null." % context)
		return true
	if value is String and value.is_empty():
		push_error("[Guard] %s: requested resource is an empty string." % context)
		return true
	return false

func is_invalid_scene(scene: String, context: String) -> bool:
	if not ResourceLoader.exists(scene):
		push_error("[Guard] %s: '%s' does not exist as a registered resource." % [context, scene])
		return true
	return false

func is_invalid_uid(uid: Variant, context: String) -> bool:
	if not uid is String:
		push_error("[Guard] %s: invalid uid, not a string." % context)
		return true
	if uid.is_empty():
		push_error("[Guard] %s: invalid uid, uid is an empty string." % context)
		return true
	if ResourceUID.text_to_id(uid) == ResourceUID.INVALID_ID:
		push_error("[Guard] %s: invalid uid, '%s' is an invalid uid string." % [context, uid])
		return true
	if not ResourceUID.has_id(ResourceUID.text_to_id(uid)):
		push_error("[Guard] %s: invalid uid, uid does not resolve to a local resource." % context)
		return true
	return false

func is_wrong_class(value: Variant, expected_class: Variant, context: String) -> bool:
	if not is_instance_of(value, expected_class):
		push_error("[Guard] %s: instance is not of expected class." % context)
		return true
	return false