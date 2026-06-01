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
var swap_actions = {
	Channel.SwapAction.EXIT: exit_channel,
	Channel.SwapAction.SWAP: swap_channel
}

func _ready() -> void:
	var boot_scene = Keeper.get_value("_nav_dest_store", "nav_checker")
	if Guard.is_unresolved(boot_scene, "main.gd:_ready"): return
	if Guard.is_invalid_scene(boot_scene, "main.gd:_ready"): return
	route_channel(boot_scene, Channel.SwapAction.EXIT)
	is_booted = true
	
func route_channel(dest: String, swap: Channel.SwapAction) -> void:
	if Guard.is_boot_valid(front, is_booted, "main.gd:route_channel"): return
	if Guard.is_unresolved(dest, "main.gd:_ready"): return
	if Guard.is_invalid_scene(dest, "main.gd:_ready"): return
	if front.get_child_count() > 0 and swap_actions.has(swap):
		swap_actions[swap].call()
	if front.get_child_count() > 0:
		var front_channel = front.get_child(0) as Channel
		if Guard.is_channel(front_channel, "main.gd:route_channel") and front_channel.channel_dest == dest:
			front_channel.channel_resume()
			return
	for child in back.get_children():
		var channel = child as Channel
		if not Guard.is_channel(channel, "main.gd:route_channel"): continue
		if channel.channel_dest != dest:
			continue
		back.remove_child(child)
		front.add_child(child)
		if Guard.is_channel(child, "main.gd:route_channel"):
			child.channel_resume() # TODO: replace with channel_unhide
		return
	start_channel(dest)

func start_daemon(dest: String) -> void:
	var script: GDScript = load(dest)
	if Guard.is_unresolved(script, "main.gd:start_daemon"): return
	var daemon_instance: Node = Node.new()
	daemon_instance.set_script(script)
	if not Guard.is_daemon(daemon_instance, "main.gd:start_daemon"):
		daemon_instance.queue_free()
		return
	under.add_child(daemon_instance)
	daemon_instance.nav_to_daemon_sig.connect(_on_nav_to_daemon_sig)
	daemon_instance.daemon_dismiss_sig.connect(_on_daemon_dismiss_sig)
	daemon_instance.nav_to_swap_sig.connect(_on_daemon_nav_to_swap_sig)
	daemon_instance.evict_back_channel_sig.connect(_on_evict_back_channel_sig)
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

func start_channel(dest: String) -> void:
	var scene: PackedScene = load(dest)
	if Guard.is_unresolved(scene, "main.gd:start_channel"): return
	var channel_instance: Node = scene.instantiate()
	if not Guard.is_channel(channel_instance, "main.gd:start_channel"):
		channel_instance.queue_free()
		return
	front.add_child(channel_instance)
	channel_instance.channel_dest = dest
	channel_instance.nav_to_swap_sig.connect(_on_channel_nav_to_swap_sig)
	channel_instance.channel_dismiss_sig.connect(_on_channel_dismiss_sig)
	channel_instance.nav_to_channel_sig.connect(_on_nav_to_channel_sig)
	channel_instance.nav_to_daemon_sig.connect(_on_nav_to_daemon_sig)
	channel_instance.channel_init()
	print("main.gd:start_channel: " + channel_instance.name + " started.") 

func swap_channel() -> void:
	var channel: Channel = front.get_child(0) as Channel
	if not Guard.is_channel(channel, "main.gd:swap_channel"): return
	channel.channel_pause() # TODO change to channel_hide
	front.remove_child(channel)
	back.add_child(channel)
	print("main.gd:swap_channel: " + channel.name + " swapped, front -> back.") 

func exit_channel() -> void:
	if front.get_child_count() == 0:
		return
	var channel: Channel = front.get_child(0) as Channel
	if not Guard.is_channel(channel, "main.gd:exit_channel"): return
	channel.channel_shutdown()
	front.remove_child(channel)
	print("main.gd:exit_channel: " + channel.name + " exited.") 
	channel.queue_free()

func evict_back_channel(dest: String) -> void:
	for child in back.get_children():
		var channel = child as Channel
		if channel and channel.channel_dest == dest:
			back.remove_child(channel)
			channel.channel_shutdown()
			print("main.gd:evict_back_channel: " + channel.name + " evicted.")
			channel.queue_free()
			return
	push_error("main.gd:evict_back_channel: no channel with dest '%s' found in back." % dest)

func is_in_back(dest: String) -> bool:
	for child in back.get_children():
		var channel = child as Channel
		if channel and channel.channel_dest == dest:
			return true
	return false

func _on_nav_to_daemon_sig(dest: String) -> void:
	start_daemon(dest)
func _on_daemon_dismiss_sig() -> void:
	exit_daemon()
func _on_daemon_nav_to_swap_sig(dest: String) -> void:
	route_channel(dest, Channel.SwapAction.SWAP)
func _on_nav_to_channel_sig(dest: String) -> void:
	route_channel(dest, Channel.SwapAction.EXIT)
func _on_channel_nav_to_swap_sig(dest: String, swap: Channel.SwapAction) -> void:
	route_channel(dest, swap)
func _on_channel_dismiss_sig() -> void:
	exit_channel()
func _on_evict_back_channel_sig(dest: String) -> void:
	evict_back_channel(dest)
