class_name ConsoleMedium
extends Medium

var _channel: ConsoleChannel = null
var _type_tween: Tween = null

func geist_shutdown() -> void:
	_log("geist_shutdown(): medium offline.")

func set_channel(channel: ConsoleChannel) -> void:
	_channel = channel

func compose(context_key: String, data: Dictionary = {}) -> void:
	if Guard.is_null_or_empty(_channel, name + ":compose"): return
	var format_string = Firm.get_value("core_text_ledger", context_key)
	if Guard.is_null_or_empty(format_string, name + ":compose"): return
	_type_out(format_string.format(data))

func set_input_constraint(max_len: int) -> void:
	if Guard.is_null_or_empty(_channel, name + ":set_input_constraint"): return
	_channel.set_input_max_length(max_len)

func _type_out(text: String, chars_per_second: float = 400.0) -> void:
	_kill_active_tween()
	_channel.prepare_for_reveal(text)
	var duration = text.length() / chars_per_second if chars_per_second > 0.0 else 0.0
	_type_tween = create_tween()
	_type_tween.tween_method(_channel.set_visible_characters, 0, text.length(), duration)

func _kill_active_tween() -> void:
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	_type_tween = null
