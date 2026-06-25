class_name PaleolithChannel
extends Channel

@onready var output: RichTextLabel = $VBoxContainer/MarginContainer/VBoxContainer/Output
@onready var input: LineEdit = $VBoxContainer/MarginContainer/VBoxContainer/Input
@onready var status_bar: RichTextLabel = $VBoxContainer/HBoxContainer/StatusBar
@onready var arc_panel: RichTextLabel = $VBoxContainer/HBoxContainer/ArcPanel
@onready var overlay_layer: CanvasLayer = $CanvasLayer
@onready var overlay_label: RichTextLabel = $CanvasLayer/Panel/CenterContainer/OverlayLabel

func channel_init() -> void:
	if not is_node_ready():
		await ready
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.visible = false
	input.grab_focus()
	input.text_submitted.connect(_on_text_submitted)
	Auteur.register("paleolith_channel", self, ["paleolith_hub", "paleolith_pocket"])

func display(text: String) -> void:
	output.text = text
	output.visible_characters = -1

func prepare_for_reveal(text: String) -> void:
	output.text = text
	output.visible_characters = 0

func set_visible_characters(count: int) -> void:
	output.visible_characters = count

func set_arc_text(text: String) -> void:
	arc_panel.text = text

func set_status_text(text: String) -> void:
	status_bar.text = text

func show_overlay(text: String) -> void:
	overlay_label.text = text.replace("\r", "")
	overlay_layer.visible = true

func hide_overlay() -> void:
	overlay_layer.visible = false

func _on_text_submitted(text: String) -> void:
	input.text = ""
	input_received.emit(text)

@warning_ignore("unused_signal")
signal input_received(text: String)
