class_name ConsoleChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input

func channel_init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input.grab_focus()
	input.text_submitted.connect(_on_text_submitted)

func set_input_max_length(value: int) -> void:
	input.max_length = value

func display(text: String) -> void:
	output.text = text
	output.visible_characters = -1

func _on_text_submitted(text: String) -> void:
	input.text = ""
	input_received.emit(text)

func prepare_for_reveal(text: String) -> void:
	output.text = text
	output.visible_characters = 0

func set_visible_characters(count: int) -> void:
	output.visible_characters = count
	
@warning_ignore("unused_signal")
signal input_received(text: String)
