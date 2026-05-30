extends Module

@onready var display: VBoxContainer = $Display
@onready var menu: RichTextLabel = $Display/Menu
@onready var input: LineEdit = $Display/Input
@onready var status_label_1: RichTextLabel = $Display/StatusBar/StatusLabel1
@onready var status_label_2: RichTextLabel = $Display/StatusBar/StatusLabel2
@onready var status_label_3: RichTextLabel = $Display/StatusBar/StatusLabel3

func module_init() -> void:
	menu.bbcode_enabled = true
	update_menu()
	input.text_submitted.connect(_on_input)
	input.text_changed.connect(_on_text_changed)
	input.grab_focus()

func module_pause() -> void:
	display.hide()

func module_resume() -> void:
	display.show()
	input.grab_focus()

func update_status() -> void:
	pass

# intentionally adjacent to update_menu() and _on_input 
var valid_inputs: Array = ["1", "2"]

func update_menu() -> void:
	menu.text = """【﻿ｔｅｍｐｌａｔｅ　ｓｃｅｎｅ】

『1』PAUSE template_menu and navigate to boot_scene
『2』CLOSE template_menu and navigate to boot_scene"""

func _on_input(text: String) -> void:	
	input.clear()
	match text:
		"1":
			Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.SWAP)
		"2":
			Nav.to_swap(self, get_nav("boot_scene"), Module.SwapAction.EXIT)
	
func _on_text_changed(new_text: String) -> void:
	if new_text not in valid_inputs:
		input.clear()
