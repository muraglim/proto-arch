class_name Module
extends Node

# Do not use _ready() in Module subclasses.
# Use module_init() instead - it fires after the module
# is fully added to the scene tree and bootstrapper wiring is complete.

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

func module_show() -> void: # TODO implement `under` container in `main` for modules that init without viewport interaction
	pass                    # FUTR `show_module` func in main for specific bootstrap orchstn on `under` models 

func nav_exit(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_exit"): return
	nav_req.emit(dest, SwapAction.EXIT)

func nav_swap(dest: String) -> void:
	if not Guard.is_nav_valid(dest, name + ":nav_swap"): return
	nav_req.emit(dest, SwapAction.SWAP)

func get_nav(key: String) -> String:
	var path = Keeper.get_value("nav_store", key)
	if path == null or path.is_empty():
		push_error(name + ": failed to retrieve uid for key - " + key)
		return ""
	return path

func offset_value(store: String, key: String, delta: float) -> void:
	var current = Keeper.get_value(store, key)
	if Guard.is_unresolved(current, name + ":offset value"): return
	Keeper.set_value(store, key, current + delta)

signal nav_req(target_module_path: String, swap: SwapAction)
