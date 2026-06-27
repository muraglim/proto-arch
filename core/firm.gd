extends Node

# Read-only facade for constant data records.
# Do not add set_value() or any mutation method here. Do not expose get_ledger().

const LEDGER_SCRIPTS: Array[String] = [
	# infrastructure
	"uid://dqki0i06ekyd5", # dest_ledger
	"uid://bjja3ixg755vw", # dep_ledger
	"uid://dnxiljrr7tsvg", # scope_ledger
	
	# project_start/profile
	"uid://bh5p5wp205m4d", # core_text_ledger
	"uid://dxmduqcmkv4w4", # profile_ledger
	
	# tealwyv
	"uid://i6liuf46emr2", # tealwyv_combat_ledger
	"uid://f2ddwcbtjqfx", # tealwyv_text_ledger
	"uid://bpk1t01kn21d2", # tealwyv_character_daemon
	
	#paleolith
	"uid://dbb4nhow24e5x", # paleolith_ledger
	"uid://u613hticam7w", #paleolith_text_ledger
	"uid://oyn4dg5uaodl", #paleolith_asset_ledger
	"uid://bsu8sr44wb447", #paleolith_deity_ledger
	"uid://ctyumklh1qnp3", #paloelith_arc_animation_ledger_2
	"uid://dga5pvhwc537f", #paleolith_event_ledger
	"uid://vthbp1fahnb3", #paleolith_location_ledger
	"uid://c8m2qmgj1j3yv" #paleolith_resource_ledger
]

var ledgers: Dictionary = {}

func _ready() -> void:
	for path in LEDGER_SCRIPTS:
		var script: GDScript = load(path)
		var instance := Node.new()
		instance.set_script(script)
		instance.name = script.resource_path.get_file().get_basename()
		add_child(instance)
		ledgers[instance.name.to_lower()] = instance

func get_value(ledger_node: String, key: String, default_value = null) -> Variant:
	if not ledgers.has(ledger_node):
		push_error("[Firm] get_value(ledger: %s, key: %s): unknown ledger" % [ledger_node, key])
		return null
	return ledgers[ledger_node].get_value(key, default_value)

func has_key(ledger_node: String, key: String) -> bool:
	if not ledgers.has(ledger_node):
		push_error("[Firm] has_key(ledger: %s, key: %s): unknown ledger" % [ledger_node, key])
		return false
	return ledgers[ledger_node].has_key(key)

func get_keys(ledger_node: String) -> Array[String]:
	if not ledgers.has(ledger_node):
		push_error("[Firm] get_keys(ledger: %s): unknown ledger" % ledger_node)
		return []
	return ledgers[ledger_node].get_keys()
