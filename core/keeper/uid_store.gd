extends Node

var data: Dictionary = {
	"startup_uid": "uid://b27eqwa55glmf"
}

func get_value(key: String) -> String:
	if not data.has(key):
		push_error("uid_store: unknown key - " + key)
		return ""
	return data[key]
