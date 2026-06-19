extends Node

var active_context: String = ""

var _registry: Dictionary = {}

func register(lens: Lens) -> void:
	_registry[lens.CONTEXT_KEY] = lens
	if active_context.is_empty():
		active_context = lens.CONTEXT_KEY

func transition(to: String, hint: String = "") -> void:
	if not _registry.has(to):
		push_error("[Scope] transition(%s): no registered instance for context '%s'." % [active_context, to])
		return
	var valid = Firm.get_value("_scope_ledger", active_context, [])
	if not to in valid:
		push_error("[Scope] transition(%s -> %s): invalid transition." % [active_context, to])
		return
	active_context = to
	_registry[to].geist_resume(hint)
