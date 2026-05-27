extends Module

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
	menu.text = """ｓｔａｒｔｕｐ ｍｅｎｕ

『1』 navigate to [u]stub[/u] [u]a[/u]"""

func _on_input(text: String) -> void:	
	input.clear()
	match text:
		"1":
			var path = Keeper.get_value("uid_store", "template_menu")
			if path == null or path.is_empty():
				push_error("startup_menu: failed to retrieve template_menu uid")
				return
			req_exit(path, Module.SwapType.CLOSE)

func _on_text_changed(new_text: String) -> void:
	if new_text not in valid_inputs:
		input.clear()
