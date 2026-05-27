extends Node

var stores: Dictionary = {}

func _ready() -> void:
	stores["uid_store"] = $UID_Store

func get_value(store: String, key: String) -> Variant:
	if not stores.has(store):
		push_error("get_value: unknown store - " + store)
		return null
	return stores[store].get_value(key)



#func modify_value(store: String, key: String, amount: int) -> void:
#	if not stores.has(store):
#		push_error("modify_value: unknown store - " + store)
#		return
#	stores[store].increment(key, amount)
