class_name Module
extends Node

# Do not use _ready() in Module subclasses.
# Use module_init() instead - it fires after the module
# is fully added to the scene tree and bootstrapper wiring is complete.

enum SwapType {
	CLOSE,
	MIGRATE
}

signal nav_req(target_module_path: String, swap: SwapType)

var module_path: String = ""

func req_exit(next_dest: String, swap: SwapType = SwapType.CLOSE) -> void:
	if next_dest == null or next_dest.is_empty():
		push_error(name + ": req_exit called with empty or null destination")
		return
	nav_req.emit(next_dest, swap)

func module_init() -> void:
	pass
	
func module_pause() -> void:
	pass
	
func module_resume() -> void:
	pass

func module_shutdown() -> void:
	pass

func get_uid(key: String) -> String:
	var path = Keeper.get_value("uid_store", key)
	if path == null or path.is_empty():
		push_error(name + ": failed to retrieve uid for key - " + key)
		return ""
	return path
