extends Module

func module_init() -> void:
	Nav.to_swap(self, get_nav("nav_checker"), Module.SwapAction.SWAP)
