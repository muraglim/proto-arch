extends Module

@onready var stats_display: RichTextLabel = $RichTextLabel

func module_init() -> void:
	# Position this text box on the right side of the screen so it doesn't overlap
	stats_display.text = "=== GLOBAL TRACKED STATS ===\n"
	_update_stats_ui()
	
	# Set up a processing loop or timer to refresh the data in real-time
	set_process(true)

func _process(_delta: float) -> void:
	_update_stats_ui()

func _update_stats_ui() -> void:
	var text = "=== GLOBAL TRACKED STATS ===\n"
	for stat_name in GlobalStats.stats:
		text += stat_name + ": " + str(GlobalStats.stats[stat_name]) + "\n"
	text += "\nPress [ESC] to close this panel."
	stats_display.text = text

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Escape Key
		# To close an overlay, we tell Main to unload us. 
		# For this simple prototype, removing ourselves safely works:
		get_parent().remove_child(self)
		module_teardown()
		queue_free()

func module_teardown() -> void:
	print("Stats Scroll overlay closed.")
