extends Node

var _channels: Dictionary = {}
var _context_map: Dictionary = {}

func register(key: String, channel: Channel, contexts: Array) -> void:
	_channels[key] = channel
	for ctx in contexts:
		_context_map[ctx] = key
	_log("register(): %s → %s" % [key, contexts])

func deregister_node(channel: Channel) -> void:
	var found_key: String = ""
	for key in _channels:
		if _channels[key] == channel:
			found_key = key
			break
	if found_key.is_empty(): return
	_channels.erase(found_key)
	for ctx in _context_map.keys():
		if _context_map[ctx] == found_key:
			_context_map.erase(ctx)
	_log("deregister_node(): %s removed." % found_key)

func on_transition(context_key: String) -> void:
	if not _context_map.has(context_key): return
	var target_key: String = _context_map[context_key]
	for key in _channels:
		_channels[key].visible = (key == target_key)
	_log("on_transition(%s): showing %s" % [context_key, target_key])

func _log(msg: String) -> void:
	print("[Auteur] %s" % msg)
