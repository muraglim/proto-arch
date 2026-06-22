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
	"profile_selection_prompt": "{profiles}\n\nType a profile name to select it:",
	"tealwyv_start_main": "Active profile: {active_profile_name}\nActive character: {active_character_name}\n\n[C]reate character \n[S]elect character \n[T]ealwyv town \n[B]ack to ProjectStart",
	"tealwyv_character_creation_prompt": "Enter a name for your new character (max {max_len} characters, leave blank to cancel):",
	"tealwyv_character_creation_empty": "Name cannot be empty. Try again:",
	"tealwyv_character_creation_forbidden": "Name contains a forbidden character. Forbidden characters: {chars}\n\nTry again:",
	"tealwyv_character_creation_taken": "That name is already taken. Try again:",
	"tealwyv_character_selection_prompt": "{characters}\n\nType a character name to select it:",
	"tealwyv_character_selection_missing": "No character by that name found.\n\n{characters}\n\nTry again:",
	"tealwyv_start_main_no_characters": "Active profile: {active_profile_name}\nActive character: {active_character_name}\n\n[C]reate character\n[T]ealwyv town\n[B]ack to ProjectStart",
	"tealwyv_already_selected": "You've only got one character and they're already selected!\n\n[C]reate another one if you'd like.\nor\n[T]ealwyv town\n[B]ack to ProjectStart",
	"tealwyv_character_creation_gender_prompt": "Select a gender:\n\n[M]ale / [F]emale / [O]ther\n\nLeave blank to cancel.",
	"tealwyv_character_creation_gender_invalid": "Invalid selection — choose [M]ale, [F]emale, or [O]ther.\n\nLeave blank to cancel.",
}
