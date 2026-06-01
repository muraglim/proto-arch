extends Channel

func channel_init() -> void:
	Nav.to_swap(self, get_nav("nav_checker"), Channel.SwapAction.SWAP)
