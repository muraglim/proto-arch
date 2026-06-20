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

func is_malformed_dest(value: Variant, context: String) -> bool:
	if not value is String:
		push_error("[Guard] %s: malformed dest - dest value is not a string." % context)
		return true
	if value.is_empty():
		push_error("[Guard] %s: malformed dest - dest value is an empty string." % context)
		return true
	if ResourceUID.text_to_id(value) == ResourceUID.INVALID_ID:
		push_error("[Guard] %s: malformed dest - '%s' is not a valid UID string." % [context, value])
		return true
	if not ResourceUID.has_id(ResourceUID.text_to_id(value)):
		push_error("[Guard] %s: malformed dest - dest UID does not resolve to a local resource." % context)
		return true
	return false
