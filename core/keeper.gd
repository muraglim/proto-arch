extends Node

# Mutabale state facade

const STORE_SCRIPTS: Array[String] = [
	# profile
	"uid://4iwjgqs37g7t", #profile_store
	
	# tealwyv
	"uid://dah77mrkcmp7c", #tealwyv_dev_store
	"uid://dnaj0b86atrx1", #tealwyv_character_store
	"uid://cm70cvnxnh10s", #tealwyv_luck_store
]

var stores: Dictionary = {}

func _ready() -> void:
	for path in STORE_SCRIPTS:
		var script: GDScript = load(path)
		var instance := Node.new()
		instance.set_script(script)
		instance.name = script.resource_path.get_file().get_basename()
		add_child(instance)
		stores[instance.name.to_lower()] = instance

func get_value(store_node: String, key: String, default_value = null) -> Variant:
	if not stores.has(store_node):
		push_error("[Keeper] get_value(store: %s, key: %s, default_value: %s): unknown store" % [store_node, key, default_value])
		return null
	return stores[store_node].get_value(key, default_value)

func set_value(store_node: String, key: String, value: Variant) -> void:
	if not stores.has(store_node):
		push_error("[Keeper] set_value(store: %s, key: %s, value: %s): unknown store" % [store_node, key, value])
		return
	stores[store_node].set_value(key, value)

func clear_value(store_node: String, key: String) -> void:
	if not stores.has(store_node):
		push_error("[Keeper] clear_value(store: %s, key: %s): unknown store" % [store_node, key])
		return
	stores[store_node].clear_value(key)

func append_value(store_node: String, key: String, value: Variant) -> void: 
	if not stores.has(store_node):
		push_error("[Keeper] append_value(store: %s, key: %s, value: %s): unknown store" % [store_node, key, value])
		return
	stores[store_node].append_value(key, value)

func has_key(store_node: String, key: String) -> bool:
	if not stores.has(store_node):
		push_error("[Keeper] has_key(store: %s, key: %s): unknown store" % [store_node, key])
		return false
	return stores[store_node].has_key(key)

func get_keys(store_node: String) -> Array[String]:
	if not stores.has(store_node):
		push_error("[Keeper] get_keys(store: %s): unknown store" % store_node)
		return []
	return stores[store_node].get_keys()

func get_store(store_node: String) -> Node:
# escape hatch: exposes raw store reference, bypasses facade pattern.
# no demonstrated use case yet — deprecate once specific 
# Keeper facade methods cover the gap.
	if not stores.has(store_node):
		push_error("[Keeper] get_store(store: %s): unknown store" % store_node)
		return null
	return stores[store_node]
