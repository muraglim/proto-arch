extends Module

@onready var input_field: LineEdit = $LineEdit
@onready var display_label: RichTextLabel = $RichTextLabel

@export_file("*.tscn") var stats_module_path: String

func module_init() -> void:
	display_label.text = "=== TEXT GAMEPLAY SANDBOX ===\nType anything. Type '/stats' to open the overlay.\n"
	input_field.text_submitted.connect(_on_text_submitted)
	
	StatsStore.increment_stat("commands_entered", 1)
	StatsStore.increment_stat("words_typed", new_text.split(" ").size())
	
	if new_text == "/stats":
		display_label.append_text("\nOpening Stats Monitor overlay...")
		# TRUE means: load the stats module, but KEEP this gameplay sandbox alive!
		req_exit(stats_module_path, true)
	else:
		display_label.append_text("\nYou processed command: " + new_text)
	input_field.clear()
	
func module_teardown() -> void:
	print("Gameplay Sandbox is being completely torn down from memory!")
