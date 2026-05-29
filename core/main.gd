extends Node

@onready var front: Node = $FrontContainer
@onready var back: Node = $BackContainer

var is_booted: bool = false
var swap_actions = {
	Module.SwapAction.EXIT: exit_module,
	Module.SwapAction.SWAP: swap_module
}

func _ready() -> void:
	var boot_scene = Keeper.get_value("nav_store", "roll_scene")
	if not Guard.is_nav_valid(boot_scene, "main.gd:_ready"): return
	go_to(boot_scene, Module.SwapAction.EXIT)
	is_booted = true
	
func go_to(dest: String, swap: Module.SwapAction) -> void:
	if Guard.is_boot_valid(front, is_booted, "main.gd:go_to"): return
	if not Guard.is_nav_valid(dest, "main.gd:go_to"): return
	if front.get_child_count() > 0 and swap_actions.has(swap):
		swap_actions[swap].call()
	for child in back.get_children():
		var module = child as Module
		if not Guard.is_module(module, "main.gd:go_to"): continue
		if module.module_dest != dest:
			continue
		back.remove_child(child)
		front.add_child(child)
		if Guard.is_module(child, "main.gd:go_to"):
			child.module_resume() # TODO: replace with module_unhide
		return
	start_module(dest)

func start_module(dest: String) -> void:
	var scene: PackedScene = load(dest)
	if Guard.is_unresolved(scene, "main.gd:start_module"): return
	var module_instance: Node = scene.instantiate()
	if not Guard.is_module(module_instance, "main.gd:start_module"):
		module_instance.queue_free()
		return
	front.add_child(module_instance)
	module_instance.module_dest = dest
	module_instance.nav_req.connect(_on_nav_req)
	module_instance.module_init()
	print("main.gd:start_module: " + module_instance.name + " started.") #breadcrumb

func swap_module() -> void:
	var module: Module = front.get_child(0) as Module
	if not Guard.is_module(module, "main.gd:swap_module"): return
	module.module_pause() # TODO change to module_hide
	front.remove_child(module)
	back.add_child(module)
	print("main.gd:swap_module: " + module.name + " swapped, front -> back.") # breadcrumb

func exit_module() -> void:
	if front.get_child_count() == 0:
		return
	var module: Module = front.get_child(0) as Module
	if not Guard.is_module(module, "main.gd:swap_module"): return
	module.module_shutdown()
	front.remove_child(module)
	print("main.gd:exit_module: " + module.name + " exited.") # breadcrumb
	module.queue_free()
	
func _on_nav_req(dest: String, swap: Module.SwapAction) -> void:
	go_to(dest, swap)
