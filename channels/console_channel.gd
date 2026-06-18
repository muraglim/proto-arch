class_name ConsoleChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_show() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.grab_focus()

func set_input_max_length(value: int) -> void:
	input.max_length = value

func display(text: String) -> void:
	output.text = text
