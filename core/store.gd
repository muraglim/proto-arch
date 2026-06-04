class_name Store
extends Node
var data = {}

@export var verbose := false

func get_value(key: String, default_value = null) -> Variant:
	if data.has(key):
		var value = data[key]
		_log("get_value(key: %s) -> found: %s" % [key, value])
		return value
	_log("get_value(key: %s) -> not found, returning default: %s" % [key, default_value])
	return default_value

func set_value(key: String, value: Variant) -> void:
	var previous = data.get(key, null)
	data[key] = value
	_log("set_value(key: %s, value: %s) -> previous: %s" % [key, value, previous])

func clear_value(key: String) -> void:
	if data.has(key):
		var old = data[key]
		data.erase(key)
		_log("clear_value(key: %s) -> erased value: %s" % [key, old])
	else:
		_log("clear_value(key: %s) -> key not found" % key)

func append_value(key: String, value: Variant) -> void:
# if key does not exist, silently initializes an empty Array
	if not data.has(key):
		data[key] = []
	elif not data[key] is Array:
		push_error("append_value(key: %s): key exists but is type %s" % [key, type_string(typeof(data[key]))])
		return
	data[key].append(value)
	_log("append_value(key: %s) -> Array now has %d items: %s" % [key, data[key].size(), data[key]])

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