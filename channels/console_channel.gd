class_name ConsoleChannel
extends Channel

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $MarginContainer/VBoxContainer/Input
@onready var overlay_layer: CanvasLayer = $OverlayLayer
@onready var overlay_label: RichTextLabel = $OverlayLayer/OverlayPanel/CenterContainer/OverlayLabel

func channel_init() -> void:
	if not is_node_ready():
		await ready
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var font_uid = Firm.get_value("uid_ledger", "perfect_dos_vga_437")
	var font = load(font_uid)
	overlay_label.add_theme_font_override("font", font)
	overlay_label.add_theme_font_size_override("font_size", 6)
	input.grab_focus()
	input.text_submitted.connect(_on_text_submitted)
	Auteur.register("console_channel", self, ["project_start"])

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

func show_overlay(text: String) -> void:
	overlay_label.text = text.replace("\r", "")
	overlay_layer.visible = true

func hide_overlay() -> void:
	overlay_layer.visible = false

@warning_ignore("unused_signal")
signal input_received(text: String)
