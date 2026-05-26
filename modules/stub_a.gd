extends Module

@onready var display: VBoxContainer = $Display
@onready var menu: RichTextLabel = $Display/Menu
@onready var input: LineEdit = $Display/Input
@onready var init_label: RichTextLabel = $Display/StatusBar/InitCount
@onready var pause_label: RichTextLabel = $Display/StatusBar/PauseCount
@onready var resume_label: RichTextLabel = $Display/StatusBar/ResumeCount

var init_count: int = 0
var pause_count: int = 0
var resume_count: int = 0

func module_init() -> void:
	menu.bbcode_enabled = true
	init_count += 1
	update_menu()
	update_status()
	input.text_submitted.connect(_on_input)
	input.text_changed.connect(_on_text_changed)
	input.grab_focus()

func module_pause() -> void:
	pause_count += 1
	update_status()
	display.hide()

func module_resume() -> void:
	resume_count += 1
	update_status()
	display.show()
	input.grab_focus()

func update_status() -> void:
	init_label.text = "init count: " + str(init_count)
	pause_label.text = "pause count: " + str(pause_count)
	resume_label.text = "resume count: " + str(resume_count)

# intentionally adjacent to update_menu() and _on_input 
var valid_inputs: Array = ["1", "2", "3", "4"]

func update_menu() -> void:
	menu.text = """【﻿ｓｔｕｂ　ａ】

『1』navigate to [u]stub[/u] [u]b[/u] and PAUSE [sub]stub a[/sub]
『2』navigate to [u]stub[/u] [u]b[/u] and CLOSE [s]stub a[/s]
『3』navigate to [u]main[/u] [u]menu[/u] and PAUSE [sub]stub a[/sub]
『4』navigate to [u]main[/u] [u]menu[/u] and CLOSE [s]stub a[/s]"""

func _on_input(text: String) -> void:	
	input.clear()
	match text:
		"1":
			req_exit("uid://lsh8xt21pm5w", Module.SwapType.MIGRATE)
		"2":
			req_exit("uid://lsh8xt21pm5w", Module.SwapType.CLOSE)
		"3":
			req_exit("uid://b27eqwa55glmf", Module.SwapType.MIGRATE)
		"4":
			req_exit("uid://b27eqwa55glmf", Module.SwapType.CLOSE)

func _on_text_changed(new_text: String) -> void:
	if new_text not in valid_inputs:
		input.clear()
