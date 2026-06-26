class_name PaleolithArcMedium
extends Medium

var _channel: PaleolithChannel = null

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

func set_channel(channel: PaleolithChannel) -> void:
	_channel = channel

func on_tick(payload: Dictionary) -> void:
	if Guard.is_null_or_empty(_channel, name + ":on_tick._channel"): return
	var tod: float = payload.get("time_of_day", 0.0)
	var time_label: String = payload.get("time_label", "")
	var day: int = payload.get("day", 1)
	var glyph: String = _get_sky_glyph(tod)
	var text: String = "%s  Day %d\n%s" % [glyph, day, time_label]
	_channel.set_arc_text(text)

func _get_sky_glyph(tod: float) -> String:
	# dawn ~0.1–0.25, dusk ~0.75–0.9, night otherwise
	if tod < 0.1 or tod >= 0.9:
		return ")"   # crescent moon
	elif tod < 0.25 or tod >= 0.75:
		return "*"   # transitional
	else:
		return "o"   # sun
