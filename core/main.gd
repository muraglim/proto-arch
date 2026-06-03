# TODO: channel show/hide lifecycle is incomplete.
# current: route_channel calls channel_resume() as standin for rehydrating a back->front swap.
# problem: start_channel calls channel_init() on cold start — if resume path ever calls init,
# display and input reset on a channel that should be restoring state, not reinitializing.
# approaches to explore:
#   1. channel_unhide() as dedicated restore path, main calls it instead of channel_resume on swap
#   2. a 'ready' signal from the channel back to main, channel self-reports when it's display-ready
#      rather than main assuming it can call lifecycle methods blindly
#   3. is_fresh: bool flag on Channel, main checks before deciding init vs unhide path
# constraint: solution must not require main to know anything about channel internals.
# do not resolve until a concrete case breaks — channel_resume works by accident of idempotent update_menu.

extends Node

@onready var front: Node = $FrontContainer
@onready var back: Node = $BackContainer
@onready var under: Node = $UnderContainer

var is_booted: bool = false
var swap_actions: Dictionary = {}	

func _ready() -> void:
	swap_actions = {
		Channel.SwapAction.EXIT: exit_channel,
		Channel.SwapAction.SWAP: swap_channel
	}
	var entry = Keeper.get_value("_nav_dest_store", "json_test_channel")
	if Guard.is_unresolved(entry, "[Main] _ready()"): return
	var boot_scene = entry["uid"]
	if Guard.is_unresolved(boot_scene, "[Main] _ready()"): return
	if Guard.is_invalid_scene(boot_scene, "[Main] _ready()"): return
	route_channel(boot_scene, Channel.SwapAction.EXIT)
	is_booted = true

func route_channel(dest: String, swap: Channel.SwapAction) -> void:
	if Guard.is_boot_valid(front, is_booted, "[Main route_channel()"): return
	if Guard.is_unresolved(dest, "[Main] route_channel()"): return
	if Guard.is_invalid_scene(dest, "Main route_channel()"): return
	var current: Channel = front.get_child(0) as Channel if front.get_child_count() > 0 else null
	if current and current.channel_dest == dest:
		current.channel_resume()
		return
	if current and swap_actions.has(swap):
		swap_actions[swap].call()
	for child in back.get_children():
		var channel = child as Channel
		if not channel or channel.channel_dest != dest: continue
		back.remove_child(child)
		front.add_child(child)
		child.channel_resume()
		return
	start_channel(dest)

func start_daemon(dest: String) -> void:
	var script: GDScript = load(dest)
	if Guard.is_unresolved(script, "[Main] start_daemon()"): return
	var daemon_instance: Node = Node.new()
	daemon_instance.set_script(script)
	daemon_instance.name = script.resource_path.get_file().get_basename()
	if not Guard.is_daemon(daemon_instance, "[Main] start_daemon()"):
		daemon_instance.queue_free()
		return
	under.add_child(daemon_instance)
	daemon_instance._connect_to_main(self)
	daemon_instance.daemon_init()
	print("[Main] start_daemon(dest: %s): %s started." % [dest, daemon_instance.name])

func daemon_dismiss() -> void:
	if under.get_child_count() == 0:
		return
	var daemon: Daemon = under.get_child(0) as Daemon
	if not Guard.is_daemon(daemon, "[Main] daemon_dismiss()"): return
	daemon.daemon_shutdown()
	under.remove_child(daemon)
	print("[Main] daemon_dismiss(): %s exited." % daemon.name)
	daemon.queue_free()

func start_channel(dest: String) -> void:
	var scene: PackedScene = load(dest)
	if Guard.is_unresolved(scene, "[Main] start_channel()"): return
	var channel_instance: Node = scene.instantiate()
	if not Guard.is_channel(channel_instance, "[Main] start_channel()"):
		channel_instance.queue_free()
		return
	front.add_child(channel_instance)
	channel_instance.channel_dest = dest
	channel_instance._connect_to_main(self)
	channel_instance.channel_init()
	print("[Main] start_channel(dest: %s): %s started." % [dest, channel_instance.name]) 

func swap_channel() -> void:
	var channel: Channel = front.get_child(0) as Channel
	if not Guard.is_channel(channel, "[Main] swap_channel()"): return
	channel.channel_pause() # TODO change to channel_hide
	front.remove_child(channel)
	back.add_child(channel)
	print("[Main] swap_channel(): %s swapped front -> back." % channel.name)

func exit_channel() -> void:
	if front.get_child_count() == 0:
		return
	var channel: Channel = front.get_child(0) as Channel
	if not Guard.is_channel(channel, "[Main] exit_channel()"): return
	channel.channel_shutdown()
	front.remove_child(channel)
	print("[Main] exit_channel(): %s exited." % channel.name)
	channel.queue_free()

func evict_back_channel(dest: String) -> void:
	for child in back.get_children():
		var channel = child as Channel
		if channel and channel.channel_dest == dest:
			back.remove_child(channel)
			channel.channel_shutdown()
			print("[Main] evict_back_channel(dest: %s): %s evicted." % [dest, channel.name])
			channel.queue_free()
			return
	push_error("[Main] evict_back_channel(dest: %s): no channel found in back." % dest)

func is_in_back(dest: String) -> bool:
	for child in back.get_children():
		var channel = child as Channel
		if channel and channel.channel_dest == dest:
			return true
	return false

func _on_nav_to_daemon(dest: String) -> void:
	start_daemon(dest)
func _on_daemon_dismiss() -> void:
	daemon_dismiss()
func _on_daemon_nav_to_swap(dest: String) -> void:
	route_channel(dest, Channel.SwapAction.SWAP)
func _on_nav_to_channel(dest: String) -> void:
	route_channel(dest, Channel.SwapAction.EXIT)
func _on_channel_nav_to_swap(dest: String, swap: Channel.SwapAction) -> void:
	route_channel(dest, swap)
func _on_channel_dismiss() -> void:
	exit_channel()
func _on_evict_back_channel(dest: String) -> void:
	evict_back_channel(dest)
