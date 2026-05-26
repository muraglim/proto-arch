extends Node

@onready var front: Node = $FrontContainer
@onready var back: Node = $BackContainer

var startup: bool = false
const MAIN_MENU_PATH = "uid://b27eqwa55glmf"

func _ready() -> void:
	go_to(MAIN_MENU_PATH, Module.SwapType.CLOSE)
	startup = true
	
func go_to(next_path: String, swap: Module.SwapType) -> void:
	if front.get_child_count() == 0 and startup:
		push_error("go_to: front is empty after startup. main menu not loaded.")
		return
	
	if front.get_child_count() > 0:	
		if swap == Module.SwapType.CLOSE:
			close_module()
		elif swap == Module.SwapType.MIGRATE:
			migrate_module()
	for child in back.get_children():
		if child.module_path != next_path:
			continue
		back.remove_child(child)
		front.add_child(child)
		if child is Module:
			child.module_resume()
			print("go_to: " + child.name + " restored from back") # breadcrumb
		else:
			push_error("go_to: non-Module found in back - " + child.name)
		return
	var module_scene: PackedScene = load(next_path)
	var module_instance: Node = module_scene.instantiate()
		
	if module_instance is Module:
		front.add_child(module_instance)
		module_instance.module_path = next_path
		module_instance.nav_req.connect(_on_nav_req)
		module_instance.module_init()
		print("go_to: " + next_path + " loaded fresh") # breadcrumb
	else:
		push_error("go_to: loaded scene is not a Module " + next_path)
		module_instance.queue_free()

func migrate_module() -> void:
	var module_migrant: Module = front.get_child(0) as Module
	if module_migrant == null:
		push_error("migrate_module: non-Module node found in front - " + front.get_child(0).name)
		return
	module_migrant.module_pause()
	front.remove_child(module_migrant)
	back.add_child(module_migrant)
	print(module_migrant.name + " migrated to back.") # breadcrumb

func close_module() -> void:
	if front.get_child_count() == 0:
		return
	var old_module: Module = front.get_child(0) as Module
	if old_module == null:
		push_error("close_module: non-Module node found in front - " + front.get_child(0).name)
		return
	old_module.module_shutdown()
	front.remove_child(old_module)
	print("close_module: " + old_module.name + " closed") # breadcrumb
	old_module.queue_free()
	
func _on_nav_req(next_path: String, swap: Module.SwapType) -> void:
	go_to(next_path, swap)
