extends Node

var _channels: Dictionary = {}
var _context_map: Dictionary = {}

func register(key: String, channel: Channel, contexts: Array) -> void:
	_channels[key] = channel
	for ctx in contexts:
		_context_map[ctx] = key
	_log("register(): %s → %s" % [key, contexts])

func on_transition(context_key: String) -> void:
	if not _context_map.has(context_key): return
	var target_key: String = _context_map[context_key]
	for key in _channels:
		_channels[key].visible = (key == target_key)
	_log("on_transition(%s): showing %s" % [context_key, target_key])

func _log(msg: String) -> void:
	print("[Auteur] %s" % msg)