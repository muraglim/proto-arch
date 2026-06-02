extends Store

func _ready() -> void:
	data = {
	"verify_to_swap_exit": {
		"verified": false,
		"timestamp": 0.0
	},
	"verify_to_swap_swap": {
		"verified": false,
		"timestamp": 0.0
	},
	"verify_evict_back_channel": {
		"verified": false,
		"timestamp": 0.0
	},
	"verify_daemon_dismiss": {
		"verified": false,
		"timestamp": 0.0
	},
	"verify_daemon_init": {
		"verified": false,
		"timestamp": 0.0		
	},
}

func nav_check_stamp(key: String) -> void:
	if not data.has(key):
		push_error("nav_check_Store.nav_check_stamp(): unknown key - " + key)
		return
	data[key]["verified"] = true
	data[key]["timestamp"] = Time.get_unix_time_from_system()

func get_verified(key: String) -> bool:
	if not data.has(key):
		push_error("nav_check_Store.get_verified(): unknown key - " + key)
		return false
	return data[key]["verified"]

func get_timestamp(key: String):
	if not data.has(key):
		push_error("nav_check_Store.get_timestamp(): unknown key - " + key)
		return null
	var ts: float = data[key]["timestamp"]
	if ts == 0.0:
		return null
	return Time.get_datetime_string_from_unix_time(int(ts))
