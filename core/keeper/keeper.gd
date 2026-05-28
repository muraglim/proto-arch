extends Node

var stores: Dictionary = {}

func _ready() -> void:
	# store keys are derived from child node names via to_lower()
	# node: UID_Store -> key: "uid_store"
	# add new stores by adding child nodes to keeper.tscn only
	for child in get_children():
		stores[child.name.to_lower()] = child

func get_value(store: String, key: String) -> Variant:
	if not stores.has(store):
		push_error("get_value: unknown store - " + store)
		return null
	return stores[store].get_value(key)

func set_value(store: String, key: String, delta: Variant) -> void:
	pass

func append_value() -> void: 
	pass
