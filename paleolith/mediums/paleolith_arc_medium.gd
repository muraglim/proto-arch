class_name PaleolithArcMedium
extends Medium

var _channel: PaleolithChannel = null

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

func on_tick(payload: Dictionary) -> void:
	if Guard.is_null_or_empty(_channel, name + ":on_tick._channel"): return
	var frames: Array = Firm.get_value("paleolith_arc_animation_ledger2", "frames", [])
	if frames.is_empty(): return
	var background: Array = Firm.get_value("paleolith_arc_background_ledger", "frames")
	var index: int = int(payload["time_of_day"] * frames.size())
	index = clampi(index, 0, frames.size() - 1)
	_channel.set_arc_text(frames[index])
	if background.size() > 0:
		var bg_index: int = int(payload["time_of_day"] * background.size())
		bg_index = clampi(index, 0, background.size() - 1)
		_channel.set_arc_background_text(background[bg_index])
	var background_color: Array = Firm.get_value("paleolith_arc_background_color_ledger", "frames")
	var bg_color_index: int = int(payload["time_of_day"] * background_color.size())
	bg_color_index = clampi(index, 0, background_color.size() -1)
	_channel.set_arc_background_color_text(background_color[bg_color_index])

func _get_sky_glyph(tod: float) -> String:
	# dawn ~0.1–0.25, dusk ~0.75–0.9, night otherwise
	if tod < 0.1 or tod >= 0.9:
		return ")"   # crescent moon
	elif tod < 0.25 or tod >= 0.75:
		return "*"   # transitional
	else:
		return "o"   # sun
