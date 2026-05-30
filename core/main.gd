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

extends Node

@onready var front: Node = $FrontContainer
@onready var back: Node = $BackContainer
@onready var under: Node = $UnderContainer

var is_booted: bool = false
var swap_actions = {
	Module.SwapAction.EXIT: exit_module,
	Module.SwapAction.SWAP: swap_module
}

func _ready() -> void:
	var boot_scene = Keeper.get_value("nav_store", "roll_scene")
	if not Guard.is_nav_valid(boot_scene, "main.gd:_ready"): return
	route_module(boot_scene, Module.SwapAction.EXIT)
	is_booted = true
	
func route_module(dest: String, swap: Module.SwapAction) -> void:
	if Guard.is_boot_valid(front, is_booted, "main.gd:route_module"): return
	if not Guard.is_nav_valid(dest, "main.gd:route_module"): return
	if front.get_child_count() > 0 and swap_actions.has(swap):
		swap_actions[swap].call()
	for child in back.get_children():
		var module = child as Module
		if not Guard.is_module(module, "main.gd:route_module"): continue
		if module.module_dest != dest:
			continue
		back.remove_child(child)
		front.add_child(child)
		if Guard.is_module(child, "main.gd:route_module"):
			child.module_resume() # TODO: replace with module_unhide
		return
	start_module(dest)

func start_daemon(dest: String) -> void:
	var scene: PackedScene = load(dest)
	if Guard.is_unresolved(scene, "main.gd:start_daemon"): return
	var daemon_instance: Node = scene.instantiate()
	if not Guard.is_daemon(daemon_instance, "main.gd:start_daemon"):
		daemon_instance.queue_free()
		return
	under.add_child(daemon_instance)
	daemon_instance.nav_to_daemon_sig.connect(_on_nav_to_daemon_sig)
	daemon_instance.daemon_exit_sig.connect(_on_daemon_exit_sig)
	daemon_instance.nav_to_module_sig.connect(_on_nav_to_module_sig)
	daemon_instance.nav_to_swap_sig.connect(_on_daemon_nav_to_swap_sig)
	daemon_instance.daemon_init()
	print("main.gd:start_daemon: " + daemon_instance.name + " started.")

func exit_daemon() -> void:
	if under.get_child_count() == 0:
		return
	var daemon: Daemon = under.get_child(0) as Daemon
	if not Guard.is_daemon(daemon, "main.gd:exit_daemon"): return
	daemon.daemon_shutdown()
	under.remove_child(daemon)
	print("main.gd:exit_daemon: " + daemon.name + " exited.")
	daemon.queue_free()

func start_module(dest: String) -> void:
	var scene: PackedScene = load(dest)
	if Guard.is_unresolved(scene, "main.gd:start_module"): return
	var module_instance: Node = scene.instantiate()
	if not Guard.is_module(module_instance, "main.gd:start_module"):
		module_instance.queue_free()
		return
	front.add_child(module_instance)
	module_instance.module_dest = dest
	module_instance.module_nav_to_swap_sig.connect(_on_module_nav_to_swap_sig)
	module_instance.module_exit_sig.connect(_on_module_exit_sig)
	module_instance.nav_to_module_sig.connect(_on_nav_to_module_sig)
	module_instance.nav_to_daemon_sig.connect(_on_nav_to_daemon_sig)
	module_instance.module_init()
	print("main.gd:start_module: " + module_instance.name + " started.") 

func swap_module() -> void:
	var module: Module = front.get_child(0) as Module
	if not Guard.is_module(module, "main.gd:swap_module"): return
	module.module_pause() # TODO change to module_hide
	front.remove_child(module)
	back.add_child(module)
	print("main.gd:swap_module: " + module.name + " swapped, front -> back.") 

func exit_module() -> void:
	if front.get_child_count() == 0:
		return
	var module: Module = front.get_child(0) as Module
	if not Guard.is_module(module, "main.gd:exit_module"): return
	module.module_shutdown()
	front.remove_child(module)
	print("main.gd:exit_module: " + module.name + " exited.") 
	module.queue_free()

func _on_nav_to_daemon_sig(dest: String) -> void:
	start_daemon(dest)
func _on_daemon_exit_sig() -> void:
	exit_daemon()
func _on_daemon_nav_to_swap_sig(dest: String) -> void:
	route_module(dest, Module.SwapAction.SWAP)
func _on_nav_to_module_sig(dest: String) -> void:
	route_module(dest, Module.SwapAction.EXIT)
func _on_module_nav_to_swap_sig(dest: String, swap: Module.SwapAction) -> void:
	route_module(dest, swap)
func _on_module_exit_sig() -> void:
	exit_module()
