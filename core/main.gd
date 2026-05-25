extends Node

@onready var primary_container: Node = $PrimaryContainer
@onready var background_container: Node = $BackgroundContainer

func _ready() -> void:
	load_module(target_module_path)

func load_module(target_module_path: String) -> void:
	var module_scene: PackedScene = load(target_module_path)
	var module_instance: Node = module_scene.instantiate()
	module_instance.nav_req.connect(load_module)
	primary_container.add_child(module_instance)

func close_module() -> void:
	if primary_container.get_child_count() == 0:
		return
	var old_module: Module = primary_container.get_child(0) as Module
	if not old_module:
		return
	old_module.module_teardown()
	primary_container.remove_child(old_module)
	old_module.queue_free()
