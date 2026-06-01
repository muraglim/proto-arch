# TODO: module show/hide lifecycle is incomplete.
# current: route_module calls module_resume() as standin for rehydrating a back->front swap.
# problem: start_module calls module_init() on cold start — if resume path ever calls init,
# display and input reset on a module that should be restoring state, not reinitializing.
# approaches to explore:
#   1. module_unhide() as dedicated restore path, main calls it instead of module_resume on swap
#   2. a 'ready' signal from the module back to main, module self-reports when it's display-ready
#      rather than main assuming it can call lifecycle methods blindly
#   3. is_fresh: bool flag on Module, main checks before deciding init vs unhide path
# constraint: solution must not require main to know anything about module internals.
# do not resolve until a concrete case breaks — module_resume works by accident of idempotent update_menu.

class_name Module
extends Control

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

func get_nav(key: String) -> String:
	var path = Keeper.get_value("nav_store", key)
	if path == null or path.is_empty():
		push_error(name + ": failed to retrieve uid for key - " + key)
		return ""
	return path

# signals are emitted externally via Nav autoload — unused_signal warnings expected
@warning_ignore("unused_signal")
signal nav_to_swap_sig(dest: String, swap: SwapAction)
@warning_ignore("unused_signal")
signal module_dismiss_sig
@warning_ignore("unused_signal")
signal evict_back_module_sig(dest: String)
@warning_ignore("unused_signal")
signal nav_to_daemon_sig(dest: String)
@warning_ignore("unused_signal")
signal daemon_dismiss_sig
# this does something, don't remove it.
@warning_ignore("unused_signal")
signal nav_to_module_sig(dest: String)
