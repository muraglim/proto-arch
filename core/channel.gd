# TODO: channel show/hide lifecycle is incomplete.
# current: route_channel calls channel_resume() as standin for rehydrating a back->front swap.
# problem: start_channel calls channel_init() on cold start — if resume path ever calls init,
# display and input reset on a channel that should be restoring state, not reinitializing.
# approaches to explore:
#   1. channel_unhide() as dedicated restore path, main calls it instead of channel_resume on swap
#   2. a 'ready' signal from the channel back to main, channel self-reports when it's display-ready
#      rather than main assuming it can call lifecycle methods blindly
#   3. is_fresh: bool flag on channel, main checks before deciding init vs unhide path
# constraint: solution must not require main to know anything about channel internals.
# do not resolve until a concrete case breaks — channel_resume works by accident of idempotent update_menu.

class_name Channel
extends Control

# Do not use _ready() in Channel subclasses.
# Use channel_init() instead - it fires after the channel
# is fully added to the scene tree and bootstrapper wiring is complete.
# daemon_init() is also available but reserved for daemon-specific use.

# Channels interact with persistent state via Keeper directly.
# Keeper.get_value(), Keeper.set_value(), Keeper.append_value()
# Do not add data primitive wrappers here.

enum SwapAction {
	EXIT,
	SWAP
}

var channel_dest: String = ""

func channel_init() -> void:
	pass

func channel_shutdown() -> void:
	pass

func channel_pause() -> void:
	pass

func channel_resume() -> void:
	pass

func channel_hide() -> void:
	pass

func channel_unhide() -> void:
	pass

func channel_show() -> void: 
	pass                    

func get_nav(key: String) -> String:
	var entry = Keeper.get_value("_nav_dest_store", key)
	if entry == null or not entry.has("uid") or entry["uid"].is_empty():
		push_error(name + ": failed to retrieve uid for key - " + key)
		return ""
	return entry["uid"]

func get_type(key: String) -> String:
	var entry = Keeper.get_value("_nav_dest_store", key)
	if entry == null or not entry.has("type"):
		push_error("_nav_dest_store.get_type(): no type for key - " + key)
		return ""
	return entry["type"]

# signals are emitted externally via Nav autoload — unused_signal warnings expected
@warning_ignore("unused_signal")
signal nav_to_swap_sig(dest: String, swap: SwapAction)
@warning_ignore("unused_signal")
signal channel_dismiss_sig
@warning_ignore("unused_signal")
signal evict_back_channel_sig(dest: String)
@warning_ignore("unused_signal")
signal nav_to_daemon_sig(dest: String)
@warning_ignore("unused_signal")
signal daemon_dismiss_sig
# this does something, don't remove it.
@warning_ignore("unused_signal")
signal nav_to_channel_sig(dest: String)
