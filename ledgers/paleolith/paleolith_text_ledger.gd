class_name PaleolithTextLedger
extends Ledger

func _ready() -> void:
	data = {
		"paleolith_hub": "Day {day} | {time_label} | {weather}\n{temp_grade}\n\nFlint: {flint}/{flint_cap}  Tinder: {tinder}/{tinder_cap}\n\n{options}",
		"paleolith_gathering_start_riverbank": "You descend to the riverbank, scanning the gravel shallows for workable stone.\n\n...",
		"paleolith_gathering_start_scrubland": "You push through the dry scrubland, searching the brittle undergrowth for tinder.\n\n...",
		"paleolith_gather_success_flint": "You pocket a piece of flint with a promising edge. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_success_tinder": "You gather a handful of dry grass and shredded bark. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_fail_flint": "Nothing suitable among the stones today.\n\n[continue]",
		"paleolith_gather_fail_tinder": "The scrubland offers little of use.\n\n[continue]",
		"paleolith_fire_stub": "[FIRE — skeleton]\n\n[continue]",
	}