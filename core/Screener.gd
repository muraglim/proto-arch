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
