extends Module

func module_init() -> void:
	await get_tree().process_frame
	Nav.to_swap(self, get_nav("nav_checker"), Module.SwapAction.SWAP)
