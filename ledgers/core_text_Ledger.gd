class_name CoreTextLedger
extends Ledger

func _ready() -> void:
	data = {
	"project_start_main": "Active profile: {active_name}\n\n[C]reate profile / [S]elect profile / [T]ealwyv",
	"profile_creation_prompt": "Enter a name for your new profile (max {max_len} characters):",
	"profile_creation_empty": "Name cannot be empty. Try again:",
	"profile_creation_forbidden": "Name contains a forbidden character. Forbidden characters: {chars}\n\nTry again:",
	"profile_creation_taken": "That name is already taken. Try again:",
	"profile_creation_max_length": "Note: {max_len} characters is the maximum length.",
	"profile_selection_prompt": "\n\nType a profile name to select it:"
}
