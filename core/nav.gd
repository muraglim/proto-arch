# BREADCRUMB: exit methods (module_exit, daemon_exit, evict_back_module) are lifecycle 
# termination, not routing — semantic mismatch with Nav as a name. Monitor if exit 
# cases grow or cause confusion, consider splitting into separate facade at that point.

extends Node

# Nav is the navigation facade autoload.
# All navigation calls route through Nav methods.
# Guard checks and signal emission are centralized here.
# Signals remain on the calling instance — Nav drives them, not owns them.

static func to_module(caller: Node, dest: String) -> void:
	if not Guard.is_nav_valid(dest, caller.name + ":to_module"): return
	if not caller.has_signal("nav_to_module_sig"):
		push_error("Nav.to_module: caller '%s' has no nav_to_module_sig signal" % caller.name)
		return
	caller.nav_to_module_sig.emit(dest)

static func to_daemon(caller: Node, dest: String) -> void:
	if not Guard.is_nav_valid(dest, caller.name + ":to_daemon"): return
	if not caller.has_signal("nav_to_daemon_sig"):
		push_error("Nav.to_daemon: caller '%s' has no nav_to_daemon_sig signal" % caller.name)
		return
	caller.nav_to_daemon_sig.emit(dest)

static func to_swap(caller: Node, dest: String, swap: Module.SwapAction) -> void:
	if not Guard.is_nav_valid(dest, caller.name + ":to_swap"): return
	if not caller.has_signal("nav_to_swap_sig"):
		push_error("Nav.to_swap: caller '%s' has no nav_to_swap_sig signal" % caller.name)
		return
	caller.nav_to_swap_sig.emit(dest, swap)

static func daemon_exit(caller: Node) -> void:
	if not caller.has_signal("daemon_exit_sig"):
		push_error("Nav.daemon_exit: caller '%s' has no daemon_exit_sig signal" % caller.name)
		return
	caller.daemon_exit_sig.emit()

static func module_exit(caller: Node) -> void:
	if not caller.has_signal("module_exit_sig"):
		push_error("Nav.module_exit: caller '%s' has no module_exit_sig signal" % caller.name)
		return
	caller.module_exit_sig.emit()

static func evict_back_module(caller: Node, dest: String) -> void:
	if not Guard.is_back_valid(Main.is_in_back(dest), caller.name + ":evict_back_module"): return
	if not caller.has_signal("evict_back_module_sig"):
		push_error("Nav.evict_back_module: caller '%s' has no evict_back_module_sig" % caller.name)
		return
	caller.evict_back_module_sig.emit(dest)
