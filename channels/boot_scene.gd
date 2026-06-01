extends Channel

@onready var menu: RichTextLabel = $Display/Menu
@onready var input: LineEdit = $Display/Input

func module_init() -> void:
	menu.bbcode_enabled = true
	update_menu()
	input.text_submitted.connect(_on_input)
	input.text_changed.connect(_on_text_changed)
	input.grab_focus()

# intentionally adjacent to update_menu() and _on_input 
var valid_inputs: Array = ["1"]

func update_menu() -> void:
	menu.text = """ｂｏｏｔ　ｍｅｎｕ

『1』 navigate to template_scene"""

func _on_input(text: String) -> void:	
	input.clear()
	match text:
		"1":
			Nav.to_swap(self, get_nav("template_scene"), Channel.SwapAction.SWAP)

func _on_text_changed(new_text: String) -> void:
	if new_text not in valid_inputs:
		input.clear()
