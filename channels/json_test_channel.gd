extends Channel

var _json_test_store: Node

func channel_init() -> void:
	_json_test_store = Keeper.get_store("_json_test_store")
	var current = Keeper.get_value("_json_test_store", "write_count")
	print("write_count before: %s" % str(current))
	Keeper.set_value("_json_test_store", "write_count", current + 1)
	var after = Keeper.get_value("_json_test_store", "write_count")
	print("write_count after: %s" % str(after))
