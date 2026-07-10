class_name PaleolithResourceLedger
extends Ledger

func _ready() -> void:
	data = {
		# materials
		"flint": {
			"label": "Flint",
			"type": "material",
			"store_key": "flint",
			"cap": 1000,
			"perishable": false,
			"gather_duration": 2.5,
			"base_success_rate": 0.6,
		},
		"tinder": {
			"label": "Tinder",
			"type": "material",
			"store_key": "tinder",
			"cap": 5,
			"perishable": false,
			"gather_duration": 2.0,
			"base_success_rate": 0.6,
		},
		"branches": {
			"label": "Branches",
			"type": "material",
			"store_key": "branches",
			"cap": 20,
			"perishable": false,
			"gather_duration": 3.0,
			"base_success_rate": 0.7,
		},
		# food — caps and perish flags are placeholders; preservation deferred
		"acacia_gum": {
			"label": "Acacia Gum",
			"type": "food",
			"store_key": "acacia_gum",
			"cap": 10,
			"perishable": false,
			"gather_duration": 2.0,
			"base_success_rate": 0.65,
		},
		"sedge_corms": {
			"label": "Sedge Corms",
			"type": "food",
			"store_key": "sedge_corms",
			"cap": 8,
			"perishable": true,
			"gather_duration": 2.5,
			"base_success_rate": 0.55,
		},
		"crayfish": {
			"label": "Crayfish",
			"type": "food",
			"store_key": "crayfish",
			"cap": 6,
			"perishable": true,
			"gather_duration": 3.0,
			"base_success_rate": 0.5,
		},
	}
