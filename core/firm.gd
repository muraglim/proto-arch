extends Node

# Firm — read-only facade for constant, authored data records.
#
# The invariant, stated honestly (what is enforced, and by what):
#   1. No mutation API. Never add set_value(), clear_value(), or any write
#      path. This facade routes reads only.                     [convention]
#   2. Container values (Dictionary/Array) are handed out as deep copies.
#      Mutating a value obtained from get_value() cannot touch the ledger.
#                                                               [mechanical]
#   3. Node handouts via ledger() are read-only by convention only —
#      GDScript cannot enforce it. Writing through a ledger reference is
#      deliberate deviance, and grep-able.                      [convention]
#   4. _ledgers is private. Bypassing the facade is deviance.   [convention]
#   5. Debug builds snapshot a structural hash of all ledger data at boot
#      and audit it at every Scope focus change. Mutation of authored data
#      fails loudly at the next context switch, with the transition edge
#      named in the error. Detection is probabilistic (32-bit hash) —
#      collision odds are negligible for a debug tripwire.
#                                                               [mechanical, debug]
#   6. Audit coverage extends only to data registered here. Resources
#      obtained by direct preload() elsewhere are invisible to the audit —
#      authored data must live behind a registered Ledger to be covered.

const LEDGER_SCRIPTS: Dictionary = {
	# infrastructure
	"uid_ledger":                            "uid://dqki0i06ekyd5",
	"dep_ledger":                            "uid://bjja3ixg755vw",
	"scope_ledger":                          "uid://dnxiljrr7tsvg",
	"cross_ref_ledger":                      "uid://dfe7m23x3sorf",

	# project_start/profile
	"core_text_ledger":                      "uid://bh5p5wp205m4d",
	"profile_ledger":                        "uid://dxmduqcmkv4w4",

	# tealwyv
	"tealwyv_combat_ledger":                 "uid://i6liuf46emr2",
	"tealwyv_text_ledger":                   "uid://f2ddwcbtjqfx", 
	"tealwyv_character_ledger":              "uid://bpk1t01kn21d2", 
	
	# paleolith
	"paleolith_ledger":                      "uid://dbb4nhow24e5x",
	"paleolith_text_ledger":                 "uid://u613hticam7w",
	"paleolith_asset_ledger":                "uid://oyn4dg5uaodl",
	"paleolith_deity_ledger":                "uid://bsu8sr44wb447", 
	"paleolith_arc_test_ledger":             "uid://uiubxbc0nwlf",
	"paleolith_arc_animation_ledger":        "uid://dw4618ppx3eh4", 
	"paleolith_arc_animation_ledger2":       "uid://ctyumklh1qnp3", 
	"paleolith_event_ledger":                "uid://dga5pvhwc537f",
	"paleolith_location_ledger":             "uid://vthbp1fahnb3",
	"paleolith_resource_ledger":             "uid://c8m2qmgj1j3yv",
	"paleolith_arc_background_ledger":       "uid://bmffmvhwgv6l3",
	"paleolith_arc_background_color_ledger": "uid://wdaxcuvk4knt", # paleolith_arc_background_color_ledger
	
	# perstalt
	"perstalt_world_ledger":                 "uid://cmun3njq2efs4",
}

var _ledgers: Dictionary = {}
var _snapshots: Dictionary = {}

func _ready() -> void:
	for declared_key in LEDGER_SCRIPTS:
		var uid: String = LEDGER_SCRIPTS[declared_key]
		var script: GDScript = load(uid)
		var instance := Node.new()
		instance.set_script(script)
		instance.name = script.resource_path.get_file().get_basename()
		if not Screener.verify_registration(uid, declared_key, instance, Ledger, "Firm._ready(%s)" % declared_key):
			instance.free()
			continue
		add_child(instance)
		_ledgers[instance.name.to_lower()] = instance
	# child _ready() runs inside add_child(), so all data dicts are
	# populated by this point — safe to snapshot.
	if OS.is_debug_build():
		for key in _ledgers:
			_snapshots[key] = _ledgers[key].data.hash()

func get_value(ledger_node: String, key: String, default_value = null) -> Variant:
	if not _ledgers.has(ledger_node):
		push_error("[Firm] get_value(ledger: %s, key: %s): unknown ledger" % [ledger_node, key])
		return null
	var value = _ledgers[ledger_node].get_value(key, default_value)
	# copy fence: containers leave as deep copies, never live references.
	if value is Dictionary or value is Array:
		return value.duplicate(true)
	return value

func ledger(ledger_key: String) -> Ledger:
	# Typed node handout for consumers holding declared-property ledgers
	# (config ledgers, etc.). Read-only by convention — see header, point 3.
	if not _ledgers.has(ledger_key):
		push_error("[Firm] ledger(%s): unknown ledger" % ledger_key)
		return null
	return _ledgers[ledger_key]

func has_key(ledger_node: String, key: String) -> bool:
	if not _ledgers.has(ledger_node):
		push_error("[Firm] has_key(ledger: %s, key: %s): unknown ledger" % [ledger_node, key])
		return false
	return _ledgers[ledger_node].has_key(key)

func get_keys(ledger_node: String) -> Array[String]:
	if not _ledgers.has(ledger_node):
		push_error("[Firm] get_keys(ledger: %s): unknown ledger" % ledger_node)
		return []
	return _ledgers[ledger_node].get_keys()

func audit(context: String = "") -> void:
	# Debug-build tripwire for facade bypass (header, point 5).
	# Snapshot dict is empty in release builds — this is a no-op there.
	if _snapshots.is_empty(): return
	for key in _ledgers:
		if _ledgers[key].data.hash() != _snapshots[key]:
			push_error("[Firm] audit(%s): ledger '%s' mutated since boot." % [context, key])
