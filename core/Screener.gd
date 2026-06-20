## Screener — context-aware validation orchestrator.
## Flattens common Guard + Fuss boilerplate into a single, flat callsite gate.
## Composes fatal integrity checks (Guard) with soft policy checks (Fuss)
## and returns false to signal the caller should halt, true to proceed.
## The exact severity of soft checks (warning vs fatal) can vary by context.

extends Node

func verify_dest(value: Variant, key: String, context: String) -> bool:
	if Guard.is_malformed_dest(value, context):
		return false
	Fuss.about_filename_key_mismatch(value, key, context)
	return true
