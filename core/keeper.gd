extends Node

var stores: Dictionary = {}

func _ready() -> void:
	# [scene tree legibility]
	# _Store node names use lowercase prefix + capital suffix (_nav_dest_Store) 
	# [Keeper dictionary keys]
	# derived via to_lower()
	# add new _Stores by adding child nodes to keeper.tscn
	# [callsite casing]
	# ("_nav_dest_store")
	for child in get_children():
		stores[child.name.to_lower()] = child

func get_value(store_node: String, key: String) -> Variant:
	if not stores.has(store_node):
		push_error("[Keeper] get_value(): unknown store - " + store_node)
		return null
	return stores[store_node].get_value(key)

func set_value(store_node: String, key: String, value: Variant) -> void:
	if not stores.has(store_node):
		push_error("[Keeper] set_value(): unknown store - " + store_node)
		return
	stores[store_node].set_value(key, value)

func clear_value(store_node: String, key: String) -> void:
	if not stores.has(store_node):
		push_error("[Keeper] clear_value(): unknown store - " + store_node)
		return
	stores[store_node].clear_value(key)

func append_value(store_node: String, key: String, value: Variant) -> void: 
	if not stores.has(store_node):
		push_error("[Keeper] append_value(): unknown store - " + store_node)
		return
	stores[store_node].append_value(key, value)

func has_key(store_node: String, key: String) -> bool:
	if not stores.has(store_node):
		push_error("[Keeper] has_key(): unknown store - " + store_node)
		return false
	return stores[store_node].has_key(key)

func get_keys(store_node: String) -> Array:
	if not stores.has(store_node):
		push_error("[Keeper] get_keys(): unknown store - " + store_node)
		return []
	return stores[store_node].get_keys()

func get_store(store_node: String) -> Node:
	if not stores.has(store_node):
		push_error("[Keeper] get_store(): unknown store - " + store_node)
		return null
	return stores[store_node]

func call_store(store_node: String, method: String, args: Array = []) -> Variant:
	#TODO edge case utility, no current use case
	if not stores.has(store_node):
		push_error("[Keeper] call_store(): unknown store - " + store_node)
		return null
	return stores[store_node].callv(method, args)

