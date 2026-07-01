class_name PaleolithTextLedger
extends Ledger

func _ready() -> void:
	data = {
		"paleolith_hub": "Day {day} - {time_label}\nWeather: {weather}\n\nFlint: {flint}/{flint_cap}  Tinder: {tinder}/{tinder_cap}\nBranches: {branches}/{branches_cap}\n{shelter_status}\n{options}",
		"paleolith_site_selection": "The valley opens before you. Where will you make camp?\n\n[1] Exposed Ridge - close to the thicket, open to the weather\n[2] Sheltered Hollow - protected from wind and rain, a longer walk",
		"paleolith_shelter_trip_clear": "You push through the dry scrub to the acacia thicket and return with an armful of thorn branches.\n\nBranches: {stockpile}/{harvest_count}\n\n[continue]",
		"paleolith_shelter_trip_lost": "The path back blurs in the low light. You find your way eventually, but the dark cost you time.\n\nBranches: {stockpile}/{harvest_count}\n\n[continue]",
		"paleolith_shelter_built": "You spend the last of the light dragging and weaving branches into a rough enclosure. It holds.\n\nQuality: {quality_label}\n\n[continue]",
		"paleolith_shelter_destroyed": "You return to find the enclosure collapsed - scattered branches, nothing more.\n\n[continue]",
		"paleolith_gather_success_branches": "You tuck some sturdy branches under your arm. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_success_flint": "You pocket a piece of flint with a promising edge. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_success_tinder": "You gather a handful of dry grass and shredded bark. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_hub": "{location_label}\n\n{material_label}: {material_count}/{material_cap}  {food_label}: {food_count}/{food_cap}\n\n{options}",
		"paleolith_gather_start_branches":    "You root around the thicket for some sturdy thorn branches.\n\n...",
		"paleolith_gather_start_flint":      "You descend to the riverbank, scanning the gravel shallows for workable stone.\n\n...",
		"paleolith_gather_start_tinder":     "You push through the dry scrubland, searching the brittle undergrowth for tinder.\n\n...",
		"paleolith_gather_start_acacia_gum": "You move through the thicket, checking the bark of the larger acacias for dried sap beads.\n\n...",
		"paleolith_gather_start_sedge_corms": "You wade into the sedge margins, digging with your fingers along the root crowns.\n\n...",
		"paleolith_gather_start_crayfish":   "You ease into the shallows, hands slow, watching the shadow-lines beneath the stones.\n\n...",
		"paleolith_gather_success_acacia_gum": "A good cluster of dried gum, resinous and clean. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_success_sedge_corms": "You pry loose a handful of firm corms from the mud. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_success_crayfish":   "Quick hands - you pull one from beneath a stone before it can back away. ({count}/{cap})\n\n[continue]",
		"paleolith_gather_fail_acacia_gum":   "The bark is bare. Either stripped already or this tree hasn't run yet.\n\n[continue]",
		"paleolith_gather_fail_sedge_corms":  "You dig for a while and come up with nothing useful.\n\n[continue]",
		"paleolith_gather_fail_crayfish":     "The shallows are empty. Whatever was here has moved on.\n\n[continue]",
		"paleolith_gather_fail_flint": "Nothing suitable among the stones today.\n\n[continue]",
		"paleolith_gather_fail_tinder": "The scrubland offers little of use.\n\n[continue]",
		"paleolith_gather_fail_branches": "The branches in this area of the thicket are all too rotted or too weak for a shelter.\n\n[continue]",
		"paleolith_fire_stub": "[FIRE - skeleton]\n\n[continue]",
		"paleolith_fire_attempt": "You strike flint against bark and urge the spark into the dry nest below.\n\n...",
		"paleolith_fire_success": "The spark catches. You breathe close and slow, and the nest glows into flame.\n\nA first fire.\n\n[continue]",
		"paleolith_fire_fail": "The flint sparks but the tinder won't take. The nest cools.\n\n[continue]",
		"paleolith_deity_reveal": "In the light of your fire, something becomes aware of you.\n\n{name}\n{flavor}\n\n[continue]",
		"paleolith_pocket_stub": "[POCKET DIMENSION - skeleton]\n\n[b]ack",
		
		# - event lens -
		"paleolith_event_travel": "The valley is quiet. You move through it.\n\n[continue]",
		"paleolith_event_return": "You pick your way back toward camp.\n\n[continue]",

		"paleolith_event_nest_prompt": "A ground bird's nest, unguarded - {yield_min} to {yield_max} eggs, still warm.\n\n[1] Leave it\n[2] Take one egg\n[3] Take two eggs\n[4] Drink one on the spot",
		"paleolith_event_nest_drink_choice": "The egg is warm. Rich.\n\nTake one with you?\n\n[Y]es  [N]o",

		"paleolith_event_nest_ignore": "You walk past and don't look back.\n\n[continue]",
		"paleolith_event_nest_drink_only": "You crack one against your teeth and swallow it whole. Enough.\n\n[continue]",

		"paleolith_event_nest_take_one_safe": "You pocket one egg and move on. Nothing stirs.\n\n[continue]",
		"paleolith_event_nest_take_one_pursued": "[stub - pursued, one egg]\n\n[continue]",
		"paleolith_event_nest_take_two_safe": "You take two and walk. The bird doesn't come.\n\n[continue]",
		"paleolith_event_nest_take_two_pursued": "[stub - pursued, two eggs]\n\n[continue]",
		"paleolith_event_nest_drink_take_one_safe": "You drink one and pocket another. Nothing follows.\n\n[continue]",
		"paleolith_event_nest_drink_take_one_pursued": "[stub - pursued, drank and took one]\n\n[continue]",
		"paleolith_event_nest_resolution": "[stub - test]"
	}
