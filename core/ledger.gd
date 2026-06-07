class_name Ledger
extends Node

# Base class for all constant data records.
# Data is authored inline in subclass _ready() and never mutated at runtime.
# Subclasses are registered to Firm's scene tree, not Keeper's.
# Retrieval is mediated through the Firm facade — do not access Ledger subclasses directly.

var data: Dictionary = {}

@export var verbose := false

func get_value(key: String, default_value = null) -> Variant:
	if data.has(key):
		var value = data[key]
		_log("get_value(key: %s) -> found: %s" % [key, value])
		return value
	_log("get_value(key: %s) -> not found, returning default: %s" % [key, default_value])
	return default_value

func has_key(key: String) -> bool:
	var exists = data.has(key)
	_log("has_key(key: %s) -> returns %s" % [key, exists])
	return exists

func get_keys() -> Array[String]:
	_log("get_keys() -> has %d keys" % data.size())
	return Array(data.keys(), TYPE_STRING, &"", null)

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)
