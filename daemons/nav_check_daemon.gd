extends Daemon

func daemon_init() -> void:
	await get_tree().process_frame
	Nav.evict_back_module(self, get_nav("nav_check_module_target"))
