extends Node

# Read-only facade for constant data records.
# Ledger subclasses are registered from Firm's scene tree on ready.
# Immutability is structural — Ledger subclasses live in Firm's scene tree, not Keeper's.
# Do not add set_value() or any mutation method here. Do not expose get_ledger().
# Node names use lowercase_prefix_Ledger convention (e.g. tealwyv_forest_Ledger).
# Dictionary keys are derived via .to_lower() — callsites use lowercase (e.g. "tealwyv_forest_ledger").

var ledgers: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		ledgers[child.name.to_lower()] = child

func get_value(ledger_node: String, key: String, default_value = null) -> Variant:
	if not ledgers.has(ledger_node):
		push_error("[Firm] get_value(ledger: %s, key: %s): unknown ledger" % [ledger_node, key])
		return null
	return ledgers[ledger_node].get_value(key, default_value)

func has_key(ledger_node: String, key: String) -> bool:
	if not ledgers.has(ledger_node):
		push_error("[Firm] has_key(ledger: %s, key: %s): unknown ledger" % [ledger_node, key])
		return false
	return ledgers[ledger_node].has_key(key)

func get_keys(ledger_node: String) -> Array[String]:
	if not ledgers.has(ledger_node):
		push_error("[Firm] get_keys(ledger: %s): unknown ledger" % ledger_node)
		return []
	return ledgers[ledger_node].get_keys()
