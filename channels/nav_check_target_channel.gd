extends Channel

func channel_init() -> void:
	await get_tree().process_frame
	Nav.to_swap(self, get_nav("nav_check_channel"), Channel.SwapAction.SWAP)
