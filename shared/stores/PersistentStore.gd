class_name PersistentStore
extends Store

var _file_path: String = ""

func _ready() -> void:
	# assumes node is a static child of Keeper in the scene tree
	# name is guaranteed to be set before _ready() fires in this context
	_file_path = "user://stores/%s.json" % name
	_init_defaults()
	load_data()

func save() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("stores"):
		dir.make_dir("stores")
	var file = FileAccess.open(_file_path, FileAccess.WRITE)
	if file == null:
		push_error("[%s] save(): failed to open file for writing" % name)
		return
	file.store_string(JSON.stringify(data, "\t"))
	_log("save(): wrote to %s" % _file_path)

func load_data() -> void:
	if not FileAccess.file_exists(_file_path):
		_log("load_data(): no save file found at %s, using defaults" % _file_path)
		return
	var file = FileAccess.open(_file_path, FileAccess.READ)
	if file == null:
		push_error("[%s] load_data(): failed to open file" % name)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("[%s] load_data(): failed to parse JSON" % name)
		return
	for key in parsed.keys():
# only loads keys that already exist in data
# intentional merge-over-defaults behavior
		if data.has(key):
			data[key] = parsed[key]
			
func _init_defaults() -> void:
# Override in subclasses to seed default data.
# Fires before load_data() in _ready(), so file values merge over these defaults.
	pass
