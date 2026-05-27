extends Node

var data: Dictionary = {
	"init_total": 0,
	"pause_total": 0,
	"resume_total": 0,
}

func increment(key: String, amount: int) -> void:
	data[key] = data.get(key, 0) + amount
	
func get_value(key: String) -> int:
	return data.get(key, 0)
