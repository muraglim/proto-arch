extends Daemon

func daemon_init() -> void:
	await get_tree().process_frame
	Keeper.get_store("_nav_check_store").nav_check_stamp("verify_daemon_init")
	Nav.evict_back_channel(self, get_nav("nav_check_target_channel"))
	Nav.daemon_dismiss(self)
