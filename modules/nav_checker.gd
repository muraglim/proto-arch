extends Module

@onready var navchecker: Label = $MarginContainer/VBoxContainer/NavChecker
@onready var status: Label = $MarginContainer/VBoxContainer/Status

func module_init() -> void:
	navchecker.text = "NavChecker"
	status.text = "[status: init]"
	await get_tree().process_frame
	#Nav.to_swap.SWAP verified 2026.05.31 14:00 CDT 
	#Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.EXIT)	
	#Nav.to_swap.SWAP verified 2026.05.31 13:58 CDT 
	#Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.SWAP)
