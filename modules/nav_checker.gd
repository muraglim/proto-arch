extends Module

@onready var navchecker: Label = $Control/MarginContainer/VBoxContainer/NavChecker
@onready var status: Label = $Control/MarginContainer/VBoxContainer/Status

func module_init() -> void:
	navchecker.text = "NavChecker"
	status.text = "[status: init]"
	await get_tree().process_frame
	Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.SWAP)
