extends Node

# Mount — dependency orchestration autoload.
# Reads dep_ledger, boots deps in order via Main, manages registry and refcounts.
# Wire execution is delegated to Linker.
#
# Main calls Mount.register_main() in _ready() before any Lens boots.
# register() is called externally by whoever boots a top-level Lens
# (Main, mount_lens(), or a "lens"-type dep cascading into a sibling) —
# a Lens does not call Mount.register(self) itself; it only self-registers
# with Scope in its own geist_init().
#
# Dep "type" values:
#   "channel" / "daemon" — leaf dependency, booted via Main, no further recursion
#   "geist"   — leaf dependency that happens to be a Geist (currently: Medium)
#   "lens"    — a sibling Lens. Boots the same way as "geist", but additionally
#               recurses into register() so the sibling's own dep_ledger entry
#               (its own channel/medium/daemons) comes up too. Shared leaf deps
#               (e.g. a console_channel referenced by both the parent and the
#               sibling) dedupe via _live_by_uid, same as any other shared dep.
#
# Shared deps are refcounted (_ref_counts, keyed by uid). A dep is only actually
# torn down via Main.dismiss_node() once every registry role referencing it has
# released it via Mount.unmount(). "lens"-type deps release by cascading unmount()
# onto the sibling itself, so the sibling's own shared holds get released in
# turn before anything underneath it is actually freed.

var _main: Node = null

var _lens_registry: Dictionary = {}
var _ref_counts: Dictionary = {}
var _live_by_uid: Dictionary = {}

func register_main(main: Node) -> void:
	_main = main
	print("Mount.register_main(Main): wired.")

func register(lens: Lens, uid: String) -> void:
	var lens_key = lens.name.to_lower()
	var deps = Firm.get_value("dep_ledger", lens_key)
	if deps == null:
		print("Mount.register(%s): no dep entry found, nothing to do." % lens_key)
		return
	_lens_registry[lens_key] = {"self": {"node": lens, "uid": uid, "type": "lens"}}
	print("Mount.register(%s): registry initialized." % lens_key)
	var sorted = deps.duplicate()
	sorted.sort_custom(func(a, b): return a["order"] < b["order"])
	for dep in sorted:
		_mount_dep(lens_key, dep)
	if Scope.active_context == lens.CONTEXT_KEY:
		lens.geist_resume()

func mount_lens(uid_key: String) -> void:
	var uid = Firm.get_value("uid_ledger", uid_key)
	if not Screener.verify_uid(uid, uid_key, "Mount.mount_lens(%s)" % uid_key): return
	var path = ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
	var lens_key = path.get_file().get_basename().to_lower()
	if _lens_registry.has(lens_key):
		print("Mount.mount_lens(%s): already live." % uid)
		return
	var instance = _main.start_geist(uid)
	if instance == null: return
	register(instance, uid)

func unmount(lens: Lens) -> void:
	var lens_key = lens.name.to_lower()
	if not _lens_registry.has(lens_key):
		print("Mount.unmount(%s): no registry found, nothing to do." % lens_key)
		return
	var registry = _lens_registry[lens_key]
	for role in registry:
		if role == "self": continue
		var entry = registry[role]
		if entry == null or entry.get("node") == null: continue
		print("Mount.unmount(%s, role: %s): releasing %s." % [lens_key, role, entry["node"].name])
		_release(entry["uid"], entry.get("type", ""))
	var self_entry = registry.get("self", null)
	_lens_registry.erase(lens_key)
	if self_entry != null and self_entry.get("node") != null and not String(self_entry["uid"]).is_empty():
		Scope.unregister(lens.CONTEXT_KEY)
		_main.dismiss_node(self_entry["uid"])
		print("Mount.unmount(%s): %s unmounted." % [lens_key, self_entry["node"].name])
	print("Mount.unmount(%s): registry cleared." % lens_key)

func _release(uid: String, type: String) -> void:
	_ref_counts[uid] = _ref_counts.get(uid, 1) - 1
	if _ref_counts[uid] > 0:
		print("Mount._release(uid: %s): refcount now %d, still in use." % [uid, _ref_counts[uid]])
		return
	_ref_counts.erase(uid)
	var node = _live_by_uid.get(uid, null)  # capture before erase
	_live_by_uid.erase(uid)
	if type == "channel" and node != null:
		Auteur.deregister_node(node)
	if type == "lens":
		var path = ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
		var lens_key = path.get_file().get_basename().to_lower()
		if _lens_registry.has(lens_key):
			unmount(_lens_registry[lens_key]["self"]["node"])
			return
	_main.dismiss_node(uid)

func _mount_dep(lens_key: String, dep: Dictionary) -> void:
	var context = _resolve_dep(dep, lens_key)
	if context.is_empty(): return
	var uid_key = context["uid_key"]
	var uid = context["uid"]
	var role = context["role"]
	var type = context["type"]
	var result = _obtain_node(uid, type)
	if result.node == null: return
	_lens_registry[lens_key][role] = {"node": result.node, "uid": uid, "type": type}
	_ref_counts[uid] = _ref_counts.get(uid, 0) + 1
	if result.is_new:
		_live_by_uid[uid] = result.node
		Echo.log_list([uid_key, uid, lens_key, dep])
		print("Mount._mount_dep(%s, role: %s): %s mounted." % [lens_key, role, result.node.name])
		if type == "lens":
			register(result.node as Lens, uid)
	else:
		print("Mount._mount_dep(%s, role: %s): already live, registering existing instance. refcount: %d" % [lens_key, role, _ref_counts[uid]])
	Linker.execute_wires(lens_key, dep, _lens_registry[lens_key])

func _resolve_dep(dep: Dictionary, lens_key: String) -> Dictionary:
	var uid_key = dep.get("uid_key", "")
	var role = dep.get("role", "")
	var type = dep.get("type", "")
	if Guard.is_null_or_empty(uid_key, "Mount._resolve_dep(%s)" % lens_key): return {}
	if Guard.is_null_or_empty(role, "Mount._resolve_dep(%s)" % lens_key): return {}
	if Guard.is_null_or_empty(type, "Mount._resolve_dep(%s)" % lens_key): return {}
	var uid = Firm.get_value("uid_ledger", uid_key)
	if not Screener.verify_uid(uid, uid_key, "Mount._resolve_dep(%s)" % uid_key): return {}
	return {"uid_key": uid_key, "uid": uid, "role": role, "type": type}

func _obtain_node(uid: String, type: String) -> Dictionary:
	var existing = _live_by_uid.get(uid, null)
	if existing != null:
		return {"node": existing, "is_new": false}
	var instance = _boot_via_main(uid, type)
	return {"node": instance, "is_new": instance != null}

func _boot_via_main(uid: String, type: String) -> Node:
	match type:
		"daemon": return _main.start_daemon(uid)
		"geist", "lens": return _main.start_geist(uid)
		"channel": return _main.start_channel(uid)
		_:
			push_error("Mount._boot_via_main(): unknown type '%s'" % type)
			return null

# no live call sites currently.
func _find_daemon_by_role(lens_key: String, role: String) -> Daemon:
	if not _lens_registry.has(lens_key): return null
	var entry = _lens_registry[lens_key].get(role, null)
	if entry == null: return null
	return entry.get("node", null) as Daemon
