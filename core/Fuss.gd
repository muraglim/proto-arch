## Fuss - non-fatal policy warnings.
## Performs domain-specific checks (naming conventions, deprecated usage, etc.)
## and logs warnings without halting execution. Functions return a bool
## indicating whether a violation was detected, empowering callers (like Screener)
## to decide whether to treat the issue as fatal in context.

extends Node

func about_filename_key_mismatch(value: Variant, key: String, context: String) -> bool:
	var uid = ResourceUID.text_to_id(value)
	var path = ResourceUID.get_id_path(uid)
	if not path.is_empty():
		var actual = path.get_file().get_basename()
		if actual != key:
			push_warning("(%s): naming mismatch - key '%s' points to '%s', but file is '%s'." % [context, key, value, actual])
			return true
	return false  
