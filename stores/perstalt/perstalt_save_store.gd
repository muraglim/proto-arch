class_name PerstaltSaveStore
extends SlottedStore

# Holds the full mutable state of exactly one Perstalt world at a time.
# Bound/unbound by perstalt_world_daemon on creation/selection/deletion.
# File: user://stores/perstalt_save_store/<world_id>.json
#
# Gameplay daemons never touch binding — they read/write through
# PerstaltDaemon.get_world_value()/set_world_value(), which guard on
# binding + profile validity.

func _init_slot_defaults() -> void:
	data = {
		"world_id": "",  # mirrors filename; orphan-file forensics
		"tiles": {},     # mutated overworld tiles only, keyed later by coord
	}
