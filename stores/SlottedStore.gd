class_name SlottedStore
extends Store

# Store whose backing file is chosen at runtime - one file per slot -
# unlike PersistentStore, which derives a single fixed path from its node
# name at _ready(). A SlottedStore is a static child of Keeper like any
# other store, but starts UNBOUND: reads fall through to defaults, writes
# are refused loudly. A daemon binds it to a slot id; from then on it
# behaves like an AutoSaveStore against user://stores/<node_name>/<slot_id>.json
#
# Not registered in Keeper directly — subclass it (see perstalt_save_store).

var _slot_id: String = ""

func is_bound() -> bool:
	return not _slot_id.is_empty()

func bind_slot(slot_id: String) -> void:
	# Rebinding while bound saves the outgoing slot first.
	if is_bound():
		unbind()
	_slot_id = slot_id
	data = {}
	_init_slot_defaults()
	if FileAccess.file_exists(_file_path()):
		_load_slot()
	else:
		save() # materialize the file at creation time
	_log("bind_slot(%s): bound, %d keys" % [slot_id, data.size()])

func unbind(save_first: bool = true) -> void:
	if not is_bound(): return
	if save_first:
		save()
	_log("unbind(): released slot %s" % _slot_id)
	_slot_id = ""
	data = {}

func delete_slot(slot_id: String) -> void:
	# If the doomed slot is currently bound, discard without saving.
	if _slot_id == slot_id:
		unbind(false)
	var path = "user://stores/%s/%s.json" % [name, slot_id]
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		_log("delete_slot(%s): file removed" % slot_id)
	else:
		_log("delete_slot(%s): no file found" % slot_id)

# --- write guards + autosave semantics ---

func set_value(key: String, value: Variant) -> void:
	if not _guard_bound("set_value(%s)" % key): return
	super.set_value(key, value)
	save()

func append_value(key: String, value: Variant) -> void:
	if not _guard_bound("append_value(%s)" % key): return
	super.append_value(key, value)
	save()

func clear_value(key: String) -> void:
	if not _guard_bound("clear_value(%s)" % key): return
	super.clear_value(key)
	save()

# --- persistence ---

func save() -> void:
	if not _guard_bound("save()"): return
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("stores"):
		dir.make_dir("stores")
	if not dir.dir_exists("stores/%s" % name):
		dir.make_dir("stores/%s" % name)
	var file = FileAccess.open(_file_path(), FileAccess.WRITE)
	if file == null:
		push_error("[%s] save(): failed to open %s for writing" % [name, _file_path()])
		return
	file.store_string(JSON.stringify(data, "\t"))
	_log("save(): wrote to %s" % _file_path())

func _load_slot() -> void:
	var file = FileAccess.open(_file_path(), FileAccess.READ)
	if file == null:
		push_error("[%s] _load_slot(): failed to open %s" % [name, _file_path()])
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("[%s] _load_slot(): failed to parse JSON at %s" % [name, _file_path()])
		return
	for key in parsed.keys():
		# merge-over-defaults, same intent as PersistentStore.load_data()
		if data.has(key):
			data[key] = parsed[key]

func _file_path() -> String:
	return "user://stores/%s/%s.json" % [name, _slot_id]

func _guard_bound(op: String) -> bool:
	if is_bound(): return true
	push_error("[%s] %s: store is not bound to a slot" % [name, op])
	return false

func _init_slot_defaults() -> void:
	# Override in subclasses to seed per-slot default data.
	pass
