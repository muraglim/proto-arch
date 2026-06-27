class_name CrossRefLedger
extends Ledger

func _ready() -> void:
	data = {
		"refs": [
			{
				"context": "location.material_node → paleolith_resource_ledger",
				"source_ledger": "paleolith_location_ledger",
				"source_key": "locations",
				"source_subkey": "",
				"ref_field": "material_node",
				"target_ledger": "paleolith_resource_ledger",
				"target_key": "",
			},
			{
				"context": "location.food_node → paleolith_resource_ledger",
				"source_ledger": "paleolith_location_ledger",
				"source_key": "locations",
				"source_subkey": "",
				"ref_field": "food_node",
				"target_ledger": "paleolith_resource_ledger",
				"target_key": "",
			},
			{
				"context": "event.unguarded_nest.location_weights → paleolith_location_ledger.locations",
				"source_ledger": "paleolith_event_ledger",
				"source_key": "unguarded_nest",
				"source_subkey": "location_weights",
				"ref_field": "",
				"target_ledger": "paleolith_location_ledger",
				"target_key": "locations",
			},
		]
	}
