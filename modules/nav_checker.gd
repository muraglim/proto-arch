extends Channel

@onready var navchecker: Label = $MarginContainer/VBoxContainer/NavChecker
@onready var status: Label = $MarginContainer/VBoxContainer/Status

#✓ Nav.to_swap(self, get_nav("nav_check_module_target"), Module.SwapAction.EXIT)	
#func module_init() -> void:
#	navchecker.text = "NavChecker"
#	status.text = "[status: init]"
#	await get_tree().process_frame
	#✓ Nav.to_swap.SWAP verified 2026.05.31 14:00 CDT 

#✓ Nav.to_swap.SWAP verified 2026.05.31 13:58 CDT 
func channel_init() -> void:
	navchecker.text = "NavChecker"
	status.text = "[status: init]"
	await get_tree().process_frame
	Nav.to_swap(self, get_nav("nav_check_channel_target"), Channel.SwapAction.SWAP)
	
#✓ Nav.evict_back_channel(..daemon origin point..) verified 2026.05.31 17:41 CDT
# // nav check case for daemon_evict_from_back
# nav_checker channel_init
# nav_checker swaps -> with nav_check_channel_target
# nav_check_channel_target swaps -> nav_checker 
# nav_check_channel_target now in back
# nav_checker channel_resume
# nav_checker calls Nav.to_daemon
# daemon_init fires
# nav_check_daemon calls Nav.evict_back_channel
#func channel_init() -> void:
#	navchecker.text = "NavChecker"
#	status.text = "[status: init]"
#	await get_tree().process_frame
#	Nav.to_swap(self, get_nav("nav_check_channel_target"), Channel.SwapAction.SWAP)
#
#func channel_resume() -> void:
#	await get_tree().process_frame
#	Nav.to_daemon(self, get_nav("nav_check_daemon"))
