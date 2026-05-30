extends Node

var stores: Dictionary = {}

func _ready() -> void:
	# store keys are derived from child node names via to_lower()
	# node: Nav_Store -> key: "nav_store"
	# add new stores by adding child nodes to keeper.tscn only
	for child in get_children():
		stores[child.name.to_lower()] = child

func get_value(store_node: String, key: String) -> Variant:
	if not stores.has(store_node):
		push_error("get_value: unknown store - " + store_node)
		return null
	return stores[store_node].get_value(key)

func set_value(store_node: String, key: String, delta: Variant) -> void:
	return

func has_value(store_node: String, key: String) -> bool:
	return false
	
func clear_value(store_node: String, key: String) -> void:
	pass

func append_value() -> void: 
	pass

func get_store(store_node: String) -> Node:
	if not stores.has(store_node):
		push_error("get_store: unknown store - " + store_node)
		return null
	return stores[store_node]

func call_store(store_node: String, method: String, args: Array = []) -> Variant:
	#TODO edge case utility, no current use case
	if not stores.has(store_node):
		push_error("call_store: unknown store - " + store_node)
		return null
	return stores[store_node].callv(method, args)
