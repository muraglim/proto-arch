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

@export var verbose := false
var _main: Node = null
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

# paired with channel_unhide() — swap cycle path (front -> back -> front)
func channel_hide() -> void:
	pass

# paired with channel_hide() — restores a previously visible channel from back
func channel_unhide() -> void:
	pass

# first render path — channel initialized directly to back, show() fires on first front promotion
# distinct from unhide() which assumes prior front visibility
func channel_show() -> void: 
	pass                    

# get_nav() and get_type() are duplicated from Daemon — residue of a prior Channel extends Daemon 
# relationship that caused scene construction errors. consolidate if a shared base becomes viable.
func get_nav(key: String) -> String:
	var entry = Firm.get_value("_nav_dest_ledger", key)
	if entry == null or not entry.has("uid") or entry["uid"].is_empty():
		_log("get_nav(key: %s): failed to retrieve uid" % key)
		return ""
	return entry["uid"]

func get_type(key: String) -> String:
	var entry = Keeper.get_value("_nav_dest_ledger", key)
	if entry == null or not entry.has("type"):
		_log("get_type(key: %s): no type found" % key)
		return ""
	return entry["type"]

func _connect_to_main(main: Node) -> void:
	_main = main
	nav_to_swap.connect(main._on_channel_nav_to_swap)
	channel_dismiss.connect(main._on_channel_dismiss)
	nav_to_channel.connect(main._on_nav_to_channel)
	nav_to_daemon.connect(main._on_nav_to_daemon)
	evict_back_channel.connect(main._on_evict_back_channel) # TODO triage evaluation re: sibling dismiss instead of evict 
	evict_daemon.connect(main._on_evict_daemon)

func wire_to_daemon(daemon: Daemon) -> void:
	pass

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)

# signals are emitted externally via Nav autoload — unused_signal warnings expected
@warning_ignore("unused_signal")
signal nav_to_swap(dest: String, swap: SwapAction)
@warning_ignore("unused_signal")
signal channel_dismiss
@warning_ignore("unused_signal")
signal evict_back_channel(dest: String)
@warning_ignore("unused_signal")
signal nav_to_daemon(dest: String)
@warning_ignore("unused_signal")
signal daemon_dismiss
@warning_ignore("unused_signal")
signal evict_daemon
# confirmed live — removing this broke routing. cause of confusion not fully parsed.
@warning_ignore("unused_signal")
signal nav_to_channel(dest: String)
