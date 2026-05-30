class_name Module
extends Daemon

# Do not use _ready() in Module subclasses.
# Use module_init() instead - it fires after the module
# is fully added to the scene tree and bootstrapper wiring is complete.
# daemon_init() is also available but reserved for daemon-specific use.

# Modules interact with persistent state via Keeper directly.
# Keeper.get_value(), Keeper.set_value(), Keeper.append_value()
# Do not add data primitive wrappers here.

enum SwapAction {
	EXIT,
	SWAP
}

var module_dest: String = ""

func module_init() -> void:
	pass

func module_shutdown() -> void:
	pass

func module_pause() -> void:
	pass

func module_resume() -> void:
	pass

func module_hide() -> void:
	pass

func module_unhide() -> void:
	pass

func module_show() -> void: 
	pass                    

func nav_exit(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_exit"): return
	swap_req.emit(dest, SwapAction.EXIT)

func nav_swap(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_swap"): return
	swap_req.emit(dest, SwapAction.SWAP)

signal swap_req(dest: String, swap: SwapAction)