## Screener — context-aware validation orchestrator.
## Flattens common Guard + Fuss boilerplate into a single, flat callsite gate.
## Composes fatal integrity checks (Guard) with soft policy checks (Fuss)
## and returns false to signal the caller should halt, true to proceed.
## The exact severity of soft checks (warning vs fatal) can vary by context.

extends Node

func verify_uid(uid: Variant, uid_key: String, context: String) -> bool:
	if Guard.is_invalid_uid(uid, context):
		return false
	Fuss.about_filename_key_mismatch(uid, uid_key, context)
	return true

func verify_ledger_refs() -> bool:
	var all_valid := true
	var registry: Array = Firm.get_value("cross_ref_ledger", "refs")
	if registry == null:
		push_error("[Screener] verify_ledger_refs(): cross_ref_ledger 'refs' not found.")
		return false

	for entry in registry:
		var context: String = entry.get("context", "?")

		# — navigate to source dict —
		var source: Variant = _navigate_source(entry, context)
		if source == null:
			all_valid = false
			continue

		# — extract refs —
		var ref_field: String = entry.get("ref_field", "")
		var refs: Array = []
		if ref_field.is_empty():
			refs = source.keys()
		else:
			for key in source:
				var val: Variant = (source[key] as Dictionary).get(ref_field, null)
				if val is String and not val.is_empty():
					refs.append(val)

		# — resolve each ref against target —
		var target_key: String = entry.get("target_key", "")
		var target_collection: Variant = null
		if not target_key.is_empty():
			target_collection = Firm.get_value(entry["target_ledger"], target_key)
			if not target_collection is Dictionary:
				push_error("[Screener] verify_ledger_refs(%s): target_key '%s' did not resolve to a Dictionary." % [context, target_key])
				all_valid = false
				continue

		for ref in refs:
			var found: bool = false
			if target_key.is_empty():
				found = Firm.get_value(entry["target_ledger"], ref) != null
			else:
				found = target_collection.has(ref)
			if not found:
				push_error("[Screener] verify_ledger_refs(%s): ref '%s' not found in target." % [context, ref])
				all_valid = false

	return all_valid

func _navigate_source(entry: Dictionary, context: String) -> Variant:
	var source: Variant = Firm.get_value(entry["source_ledger"], entry["source_key"])
	if not source is Dictionary:
		push_error("[Screener] verify_ledger_refs(%s): source_key '%s' did not resolve to a Dictionary." % [context, entry["source_key"]])
		return null
	var subkey: String = entry.get("source_subkey", "")
	if subkey.is_empty():
		return source
	var nested: Variant = source.get(subkey, null)
	if not nested is Dictionary:
		push_error("[Screener] verify_ledger_refs(%s): source_subkey '%s' did not resolve to a Dictionary." % [context, subkey])
		return null
	return nested
