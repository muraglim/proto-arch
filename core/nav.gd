# BREADCRUMB: exit methods (module_dismiss, daemon_dismiss, evict_back_module) are lifecycle 
# termination, not routing — semantic mismatch with Nav as a name. Monitor if exit 
# cases grow or cause confusion, consider splitting into separate facade at that point.

extends Node

# Nav is the navigation facade autoload.
# All navigation calls route through Nav methods.
# Guard checks and signal emission are centralized here.
# Signals remain on the calling instance — Nav drives them, not owns them.

func to_module(caller: Node, dest: String) -> void:
	if Guard.is_invalid_scene(dest, caller.name): return
	if Guard.is_unresolved(dest, caller.name + ":to_module"): return 
	if not caller.has_signal("nav_to_module_sig"):
		push_error("Nav.to_module: caller '%s' has no nav_to_module_sig signal" % caller.name)
		return
	caller.nav_to_module_sig.emit(dest)

func to_daemon(caller: Node, dest: String) -> void:
	if Guard.is_unresolved(dest, caller.name + ":to_daemon"): return
	if not caller.has_signal("nav_to_daemon_sig"):
		push_error("Nav.to_daemon: caller '%s' has no nav_to_daemon_sig signal" % caller.name)
		return
	caller.nav_to_daemon_sig.emit(dest)

func to_swap(caller: Node, dest: String, swap: Module.SwapAction) -> void:
	if Guard.is_invalid_scene(dest, caller.name): return
	if Guard.is_unresolved(dest, caller.name + ":to_module"): return 
	if not caller.has_signal("nav_to_swap_sig"):
		push_error("Nav.to_swap: caller '%s' has no nav_to_swap_sig signal" % caller.name)
		return
	caller.nav_to_swap_sig.emit(dest, swap)

func daemon_dismiss(caller: Node) -> void:
	if not caller.has_signal("daemon_dismiss_sig"):
		push_error("Nav.daemon_dismiss: caller '%s' has no daemon_dismiss_sig signal" % caller.name)
		return
	caller.daemon_dismiss_sig.emit()

func module_dismiss(caller: Node) -> void:
	if not caller.has_signal("module_dismiss_sig"):
		push_error("Nav.module_dismiss: caller '%s' has no module_dismiss_sig signal" % caller.name)
		return
	caller.module_dismiss_sig.emit()

func evict_back_module(caller: Node, dest: String) -> void:
# remnant from Main as autoload which lead to double instantiation
# Main references to the back container locally and owns this guard 
#	if not Guard.is_back_valid(Main.is_in_back(dest), caller.name + ":evict_back_module"): return
	if not caller.has_signal("evict_back_module_sig"):
		push_error("Nav.evict_back_module: caller '%s' has no evict_back_module_sig" % caller.name)
		return
	caller.evict_back_module_sig.emit(dest)
