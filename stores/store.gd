class_name Store
extends Node
var data = {}

@export var verbose := true

func _log(msg: String) -> void:
	if verbose:
		print("[Store] ", msg)

func set_value(key: Variant, value: Variant) -> void:
	# MIN: data[key] = value
	_log("set_value(key=%s, value=%s)" % [str(key), str(value)])
	var previous = data.get(key, null)
	data[key] = value
	_log("  -> previous: %s" % str(previous))

func get_value(key: Variant, default_value = null) -> Variant:
	# MIN: return data.get(key, default_value)
	_log("get_value(key=%s, default=%s)" % [str(key), str(default_value)])
	if data.has(key):
		var value = data[key]
		_log("  -> found: %s" % str(value))
		return value
	_log("  -> not found, returning default: %s" % str(default_value))
	return default_value

func append_value(key: Variant, value: Variant) -> void:
	# MIN: 
	#   if not data.has(key): data[key] = []
	#   data[key].append(value)
	_log("append_value(key=%s, value=%s)" % [str(key), str(value)])
	if not data.has(key):
		data[key] = []
		_log("  -> created new array")
	elif not data[key] is Array:
		_log("  -> ERROR: key exists but is not Array (type: %s)" % typeof_string(data[key]))
		push_error("append_value on non-array key: %s" % key)
		return
	data[key].append(value)
	_log("  -> array now has %d items: %s" % [data[key].size(), str(data[key])])

func clear_value(key: Variant) -> void:
	# MIN: data.erase(key)
	_log("clear_value(key=%s)" % str(key))
	if data.has(key):
		var old = data[key]
		data.erase(key)
		_log("  -> erased value: %s" % str(old))
	else:
		_log("  -> key not found, nothing to clear")

func has_key(key: Variant) -> bool:
	# MIN: return data.has(key)
	_log("has_key(key=%s)" % str(key))
	var exists = data.has(key)
	_log("  -> returns %s" % str(exists))
	return exists

func typeof_string(value: Variant) -> String:
	return type_string(typeof(value))
