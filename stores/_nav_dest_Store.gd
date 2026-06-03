extends Store

func _ready() -> void:
	data = {
		"nav_check_channel": {
			"uid": "uid://q6r1tmxt62gl",
			"type": "channel"
		},
		"nav_check_target_channel": {
			"uid": "uid://bigtqsohrf3g1",
			"type": "channel"
		},
		"nav_check_daemon": {
			"uid": "uid://v6kjkq4xp532",
			"type": "daemon"
		},
		"json_test_channel": {
			"uid": "uid://c882gc6fedrvw",
			"type": "channel"
		},
	}
	print("_nav_dest_Store data: ", data)
	print("_nav_dest_Store data type: ", typeof(data))
