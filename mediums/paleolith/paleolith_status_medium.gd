class_name PaleolithStatusMedium
extends Medium

var _channel: PaleolithChannel = null

func geist_shutdown() -> void:
	_log("geist_shutdown(): offline.")

func on_tick(payload: Dictionary) -> void:
	if Guard.is_null_or_empty(_channel, name + ":on_tick._channel"): return
	var ambient: float = payload.get("ambient_temp", 0.0)
	var character: float = payload.get("character_temp", 0.0)
	var grade: String = payload.get("temp_grade", "")
	var text: String = "air %.1f°  body %.1f°  [%s]" % [ambient, character, grade]
	_channel.set_status_text(text)