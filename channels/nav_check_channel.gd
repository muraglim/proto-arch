extends Channel

@onready var label_path: Label = $MarginContainer/VBoxContainer/LabelPath
@onready var label_status: Label = $MarginContainer/VBoxContainer/LabelStatus
@onready var label_results: Label = $MarginContainer/VBoxContainer/LabelResults

@export_enum(
	"verify_to_swap_exit",
	"verify_to_swap_swap",
	"verify_evict_back_channel",
	"verify_daemon_dismiss"
) var current_test: String = "verify_to_swap_swap"

var _nav_check_store: Node

func channel_init() -> void:
	_nav_check_store = Keeper.get_store("_nav_check_store")
	label_path.text = "nav_check_channel"
	label_status.text = "[status: init]"
	_update_results()
	await get_tree().process_frame
	match current_test:
		"verify_to_swap_exit":
			Nav.to_swap(self, get_nav("nav_check_target_channel"), Channel.SwapAction.EXIT)
		"verify_to_swap_swap":
			Nav.to_swap(self, get_nav("nav_check_target_channel"), Channel.SwapAction.SWAP)
		"verify_evict_back_channel":
			Nav.to_swap(self, get_nav("nav_check_target_channel"), Channel.SwapAction.SWAP)
		"verify_daemon_dismiss":
			Nav.to_swap(self, get_nav("nav_check_target_channel"), Channel.SwapAction.SWAP)

func channel_resume() -> void:
	label_status.text = "[status: resume]"
	_update_results()
	await get_tree().process_frame
	match current_test:
		"verify_evict_back_channel":
			Nav.to_daemon(self, get_nav("nav_check_daemon"))
		"verify_daemon_dismiss":
			Nav.to_daemon(self, get_nav("nav_check_daemon"))

func _update_results() -> void:
	var lines: Array = []
	for key in _nav_check_store.data.keys():
		var verified: bool = _nav_check_store.get_verified(key)
		var timestamp = _nav_check_store.get_timestamp(key)
		var ts_display: String = timestamp if timestamp != null else "unverified"
		lines.append("%s — %s — %s" % [key, str(verified), ts_display])
	label_results.text = "\n".join(lines)
