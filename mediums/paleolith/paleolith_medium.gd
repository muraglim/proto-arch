class_name PaleolithMedium
extends Medium

var _channel: Channel = null
var _type_tween: Tween = null
var _animation_tween: Tween = null

signal animation_complete

func geist_shutdown() -> void:
	_kill_tween()
	_kill_animation_tween()
	_log("geist_shutdown(): offline.")

func compose(context_key: String, data: Dictionary = {}) -> void:
	if Guard.is_null_or_empty(_channel, name + ":compose._channel"): return
	var format_string = Firm.get_value("paleolith_text_ledger", context_key)
	if Guard.is_null_or_empty(format_string, name + ":compose.%s" % context_key): return
	var text: String = format_string.format(data) if not data.is_empty() else format_string
	_type_out(text, _get_typewriter_config(context_key))

func display_raw(text: String) -> void:
	if Guard.is_null_or_empty(_channel, name + ":display_raw"): return
	_type_out(text, _get_typewriter_config("default"))

func show_overlay(asset_key: String) -> void:
	if Guard.is_null_or_empty(_channel, name + ":show overlay"): return
	var assets: Array = Firm.get_value("paleolith_asset_ledger", asset_key, [])
	if assets.is_empty(): return
	_channel.show_overlay(assets[randi() % assets.size()].get("text", ""))

func hide_overlay() -> void:
	if Guard.is_null_or_empty(_channel, name + ":hide_overlay"): return
	_channel.hide_overlay()

func show_animated_overlay(frames: Array, interval: float = 0.6) -> void:
	if Guard.is_null_or_empty(_channel, name + ":show_animated_overlay"): return
	_kill_animation_tween()
	if frames.is_empty():
		animation_complete.emit()
		return
	_channel.show_overlay(frames[0])
	_animation_tween = create_tween()
	for i in range(1, frames.size()):
		_animation_tween.tween_interval(interval)
		_animation_tween.tween_callback(_channel.show_overlay.bind(frames[i]))
	_animation_tween.tween_interval(interval)
	_animation_tween.tween_callback(func(): animation_complete.emit())

func _kill_animation_tween() -> void:
	if _animation_tween != null and _animation_tween.is_valid():
		_animation_tween.kill()
	_animation_tween = null

func _get_typewriter_config(context_key: String) -> Dictionary:
	var configs: Dictionary = Firm.get_value("paleolith_ledger", "typewriter_configs", {})
	if configs.has(context_key):
		return configs[context_key]
	return configs.get("default", {"chars_per_second": 60.0, "initial_delay": 0.0})

func _type_out(text: String, config: Dictionary) -> void:
	_kill_tween()
	_channel.prepare_for_reveal(text)
	var cps: float = config.get("chars_per_second", 60.0)
	var delay: float = config.get("initial_delay", 0.0)
	var duration: float = float(text.length()) / cps if cps > 0.0 else 0.0
	_type_tween = create_tween()
	if delay > 0.0:
		_type_tween.tween_interval(delay)
	_type_tween.tween_method(_channel.set_visible_characters, 0, text.length(), duration)

func _kill_tween() -> void:
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	_type_tween = null
