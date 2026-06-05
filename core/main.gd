extends Node

@onready var front: Node = $FrontContainer
@onready var back: Node = $BackContainer
@onready var under: Node = $UnderContainer

var is_booted: bool = false
var swap_actions: Dictionary = {}

func _ready() -> void:
# dispatch table: maps SwapAction enum values to their handler functions
	swap_actions = {
		Channel.SwapAction.EXIT: dismiss_channel,
		Channel.SwapAction.SWAP: swap_channel
	}
	var entry = Keeper.get_value("_nav_dest_store", "tealwyv_forest_channel")
	if Guard.is_unresolved(entry, "[Main] _ready()"): return
	var boot_scene = entry["uid"]
	if Guard.is_unresolved(boot_scene, "[Main] _ready()"): return
	if Guard.is_invalid_scene(boot_scene, "[Main] _ready()"): return
	route_channel(boot_scene, Channel.SwapAction.EXIT)
	is_booted = true

func route_channel(dest: String, swap: Channel.SwapAction) -> void:
	if Guard.is_front_empty_after_boot(front, is_booted, "[Main] route_channel()"): return
	if Guard.is_unresolved(dest, "[Main] route_channel()"): return
	if Guard.is_invalid_scene(dest, "[Main] route_channel()"): return
	var current: Channel = front.get_child(0) as Channel if front.get_child_count() > 0 else null
	if current and current.channel_dest == dest:
		current.channel_resume()
		return
	if current and swap_actions.has(swap):
		swap_actions[swap].call()
	var cached = _find_back_channel(dest)
	if cached:
		back.remove_child(cached)
		front.add_child(cached)
		cached.channel_resume()
		return
	start_channel(dest)

func start_daemon(dest: String) -> void:
# Daemons are script-only, no invalid scene guard needed 
# TODO: consider guard against passing a scene uid as dest
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
	_on_daemon_started(daemon_instance)
	print("[Main] start_daemon(dest: %s): %s started." % [dest, daemon_instance.name])

# dismiss: called by a Daemon self-dismiss from under, or a sibling Daemon triggering sibling dismiss
func daemon_dismiss(dest: String) -> void:
	var daemon = _find_daemon(dest)
	if not Guard.is_daemon(daemon, "[Main] daemon_dismiss()"): return
	daemon.daemon_shutdown()
	under.remove_child(daemon)
	print("[Main] daemon_dismiss(): %s dismissed." % daemon.name)
	daemon.queue_free()

# evict: called across container type boundaries (Channel evicting Daemon or vice versa)
func evict_daemon(dest: String) -> void:
	print("[Main] evict_daemon(): searching for '%s'", dest.get_file().get_basename())
	for child in under.get_children():
		print(" - under child: '%s'" % child.name)
	var daemon = _find_daemon(dest)
	if not Guard.is_daemon(daemon, "[Main] evict_daemon()"): return
	daemon.daemon_shutdown()
	under.remove_child(daemon)
	print("[Main] evict_daemon(): %s evicted." % daemon.name)
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
	channel.channel_pause()
	front.remove_child(channel)
	back.add_child(channel)
	print("[Main] swap_channel(): %s swapped front -> back." % channel.name)

# dismiss: called by a Channel self-dismiss from back, or a sibling Channel triggering sibling dismiss
func dismiss_channel() -> void:
	if front.get_child_count() == 0:
		return
	var channel: Channel = front.get_child(0) as Channel
	if not Guard.is_channel(channel, "[Main] dismiss_channel()"): return
	channel.channel_shutdown()
	front.remove_child(channel)
	print("[Main] dismiss_channel(): %s dismissed." % channel.name)
	channel.queue_free()

# evict: called across container type boundaries (Channel evicting Daemon or vice versa)
func evict_back_channel(dest: String) -> void:
	var channel = _find_back_channel(dest)
	if not channel:
		push_error("[Main] evict_back_channel(dest: %s): no channel found in back." % dest)
		return
	back.remove_child(channel)
	channel.channel_shutdown()
	print("[Main] evict_back_channel(dest: %s): %s evicted." % [dest, channel.name])
	channel.queue_free()

func is_in_back(dest: String) -> bool:
	return _find_back_channel(dest) != null

func is_in_under(dest: String) -> bool:
	return _find_daemon(dest) != null

func _find_back_channel(dest: String) -> Channel:
	for child in back.get_children():
		var channel = child as Channel
		if channel and channel.channel_dest == dest:
			return channel
	return null

func _find_daemon(dest: String) -> Daemon:
	var path := dest
	if dest.begins_with("uid://"):
		path = ResourceUID.get_id_path(ResourceUID.text_to_id(dest))
	var target_name := path.get_file().get_basename()
	for child in under.get_children():
		var daemon = child as Daemon
		if daemon and daemon.name == target_name:
			return daemon
	return null

#KLDG see: tealwyv_forest_channel set_combat_daemon()
func _on_daemon_started(daemon: Daemon) -> void:
	var channel = front.get_child(0) as Channel
	if channel and channel.has_method("set_combat_daemon"):
			channel.set_combat_daemon(daemon)

func _on_nav_to_daemon(dest: String) -> void:
	start_daemon(dest)
func _on_daemon_dismiss(dest: String) -> void:
	daemon_dismiss(dest)
func _on_daemon_nav_to_swap(dest: String) -> void:
	route_channel(dest, Channel.SwapAction.SWAP)
func _on_nav_to_channel(dest: String) -> void:
	route_channel(dest, Channel.SwapAction.EXIT)
func _on_channel_nav_to_swap(dest: String, swap: Channel.SwapAction) -> void:
	route_channel(dest, swap)
func _on_channel_dismiss() -> void:
	dismiss_channel()
func _on_evict_back_channel(dest: String) -> void:
	evict_back_channel(dest)
func _on_evict_daemon(dest: String) -> void:
	evict_daemon(dest)
