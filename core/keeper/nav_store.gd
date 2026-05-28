extends Node

var data: Dictionary = {
	"boot_scene": "uid://b27eqwa55glmf",
	"template_scene": "uid://sew0lmp877f3"
	}

func get_value(key: String) -> String:
	if not data.has(key):
		push_error("nav_store: unknown key - " + key)
		return ""
	return data[key]
