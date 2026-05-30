# ── TODO ──────────────────────────────────────────
# name step: duplicate check against Roster_Store, bark loop on collision,
# suggest random name (predetermined list or assembled from parts),
# escape back to entry or accept suggestion
# ──────────────────────────────────────────────────
# staged_zodiac: float range is a time_since_current_year(start) delta
# assigns rng in this range, change from rng to instead reflect world time state
# ──────────────────────────────────────────────────
# constrained_inputs: assign as empty array for template, provide inputs per step
# ──────────────────────────────────────────────────
# update_status(): stub with no gameplay context currently
# decide ideal placement alongside update_menu() when context provides

extends Module

@onready var display: VBoxContainer = $Display
@onready var menu: RichTextLabel = $Display/Menu
@onready var input: LineEdit = $Display/Input
@onready var status_label_1: RichTextLabel = $Display/StatusBar/StatusLabel1
@onready var status_label_2: RichTextLabel = $Display/StatusBar/StatusLabel2
@onready var status_label_3: RichTextLabel = $Display/StatusBar/StatusLabel3

const HEADER: String = "【𝔯𝔬𝔩𝔩🎲𝔰𝔠𝔢𝔫𝔢】"
var prompt: String = ""
var options: String = ""
var status: String = ""

var staged_name: String = ""
var staged_id = int(Time.get_unix_time_from_system())
var staged_gender: bool = false
var staged_origin: String = "player"
var staged_zodiac: float = 0.0
var is_input_constrained = true
var roll_step: String = "menu"
var loop_count: int = 0

var constrained_inputs: Array = ["1", "2", "3"] 

func module_init() -> void:
	menu.bbcode_enabled = true
	update_menu()
	input.text_submitted.connect(_on_input)
	input.text_changed.connect(_on_text_changed)
	input.grab_focus()

func module_pause() -> void:
	print("roll_scene: module_pause fired")
	display.hide()

func module_resume() -> void:
	display.show()
	input.grab_focus()

func module_shutdown() -> void:
	display.hide()

func update_menu() -> void:
	match roll_step:
		"menu":
			prompt = "『1』roll new character\n『2』PAUSE\n『3』CLOSE"
		"name":
			prompt = "enter a name for your character! hurry up!" 
		"gender":
			match loop_count:
				0: prompt = "okay, are you boy or a girl?『1』male 『2』female『3』it's a secret"
				1: prompt = "just answer the question!!!! 『1』male 『2』female『3』why do you need to know?"
				_: prompt = "WE'RE TESTING A BOOL!!!!!!!! 『1』male 『2』female『3』what's a bool?"
		"confirm":
			var gender_display = "male" if not staged_gender else "female"
			prompt = "is this correct?\n\nname: %s\ngender: %s\nzodiac: %s\nid: %s\n\n 『1』confirm 『2』start over" % [staged_name, gender_display, str(staged_zodiac),str(staged_id)]
	menu.text = HEADER + "\n" + prompt

func update_status() -> void: 
	pass

func _on_input(text: String) -> void:	
	input.clear()
	if roll_step == "menu":
		match text:
			"1":
				is_input_constrained = false
				roll_step = "name"
				update_menu()
			"2":
				Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.SWAP)
			"3":
				Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.EXIT)
	else:
		_handle_roll_input(text)

func _on_text_changed(new_text: String) -> void:
	if is_input_constrained and new_text not in constrained_inputs:
		input.clear()

func _handle_roll_input(text: String) -> void:
	match roll_step:
		"name":
			staged_name = text
			is_input_constrained = true
			loop_count = 0
			roll_step = "gender"
			update_menu()
		"gender":
			if text == "1":
				staged_gender = false
				staged_id = Time.get_unix_time_from_system()
				staged_zodiac = randf_range(0.0, 22.828125)
				_advance_step("confirm")
			elif text == "2":
				staged_gender = true
				staged_id = Time.get_unix_time_from_system()
				staged_zodiac = randf_range(0.0, 22.828125)
				_advance_step("confirm")
			elif text == "3":
				loop_count += 1
				update_menu()
		"confirm":
			if text == "1":
				Keeper.get_store("roster_store").add_to_roster(staged_name, staged_id, staged_gender, staged_origin, staged_zodiac)
				_advance_step("menu")
			elif text == "2":
				staged_name = ""
				staged_gender = false
				staged_zodiac = 0.0
				_advance_step("menu")
			
func _advance_step(next_step: String) -> void:
	roll_step = next_step
	loop_count = 0
	update_menu()
