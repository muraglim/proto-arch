class_name PerstaltWorldStore
extends AutoSaveStore

# Index of all Perstalt worlds across all profiles — metadata only
# (id, name, profile_id, seed, created_at). Heavy per-world state lives
# in perstalt_save_store, one file per world id. This split keeps the
# always-loaded roster tiny while world files grow with tile mutations.
#
# NOTE: seed round-trips through JSON as a float — cast int() at the
# point of consumption (RandomNumberGenerator.seed is int64).

func _init_defaults() -> void:
	data = {
		"worlds": [],
		"active_world_id": "",
	}
