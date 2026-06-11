# BREADCRUMB: exit methods (channel_dismiss, daemon_dismiss, evict_back_channel) are lifecycle 
# termination, not routing — semantic mismatch with Nav as a name. Monitor if exit 
# cases grow or cause confusion, consider splitting into separate facade at that point.
# TODO: conform logging to project convention

extends Node

# Nav is the navigation facade autoload.
# All navigation calls route through Nav methods.
# Guard checks and signal emission are centralized here.
# Signals remain on the calling instance — Nav drives them, not owns them.

func to_channel(caller: Node, dest: String) -> void:
	if Guard.is_invalid_scene(dest, caller.name): return
	if Guard.is_unresolved(dest, caller.name + ":to_channel"): return 
	if not caller.has_signal("nav_to_channel"):
		push_error("Nav.to_channel: caller '%s' has no nav_to_channel signal" % caller.name)
		return
	caller.nav_to_channel.emit(dest)

func to_daemon(caller: Channel, dest: String) -> void:
# Daemons are script-only, no invalid scene guard needed 
# TODO: consider guard against passing a scene uid as dest
	if Guard.is_unresolved(dest, caller.name + ":to_daemon"): return
	if not caller.has_signal("nav_to_daemon"):
		push_error("Nav.to_daemon: caller '%s' has no nav_to_daemon signal" % caller.name)
		return
	caller.nav_to_daemon.emit(caller, dest)

func to_swap(caller: Node, dest: String, swap: Channel.SwapAction) -> void:
	if Guard.is_invalid_scene(dest, caller.name): return
	if Guard.is_unresolved(dest, caller.name + ":to_swap"): return 
	if not caller.has_signal("nav_to_swap"):
		push_error("Nav.to_swap: caller '%s' has no nav_to_swap signal" % caller.name)
		return
	caller.nav_to_swap.emit(dest, swap)

func daemon_dismiss(caller: Node) -> void:
	if not caller.has_signal("daemon_dismiss"):
		push_error("Nav.daemon_dismiss: caller '%s' has no daemon_dismiss signal" % caller.name)
		return
	caller.daemon_dismiss.emit(caller.get_script().resource_path)

func evict_daemon(caller: Node, dest: String) -> void:
	if not caller.has_signal("evict_daemon"):
		push_error("Nav.evict_daemon: caller '%s' has no evict_daemon signal" % caller.name)
		return
	caller.evict_daemon.emit(dest)

func evict_back_channel(caller: Node, dest: String) -> void:
	if not caller.has_signal("evict_back_channel"):
		push_error("Nav.evict_back_channel: caller '%s' has no evict_back_channel" % caller.name)
		return
	caller.evict_back_channel.emit(dest)

func to_back_start(caller: Node, dest: String) -> void:
	if not caller.has_signal("nav_to_back_start"):
		push_error("Nav.to_back_start: caller '%s' has no nav_to_back_start signal." % caller.name)
		return
	caller.nav_to_back_start.emit(dest)
