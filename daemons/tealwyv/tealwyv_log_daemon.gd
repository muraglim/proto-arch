class_name TealwyvLogDaemon
extends Daemon

# dispatch point for log contexts — combat is the only branch built out.
# future event types get their own _on_*_concluded() handlers
# and _log_*_to_csv() branches here.
# in-game logging surfaces (store, submenu) added as branches within each handler.

@export var log_to_csv := false

func wire_to_channel(channel: Channel) -> void:
	var forest = channel as TealwyvForestChannel
	if forest == null: return
	forest.register_log_daemon(self)

func _on_combat_concluded(summary: Dictionary) -> void:
	if log_to_csv:
		_log_combat_to_csv(summary)

func _log_combat_to_csv(summary: Dictionary) -> void:
	var path = "user://tealwyv_combat_log.csv"
	var write_header = not FileAccess.file_exists(path)
	var file = FileAccess.open(path, FileAccess.READ_WRITE if not write_header else FileAccess.WRITE)
	if file == null:
		push_error("[TealwyvLogDaemon] _log_combat_to_csv(): could not open %s" % path)
		return
	if write_header:
		file.store_line("timestamp,outcome,enemy_name,enemy_level,enemy_archetype,player_atk,player_def,player_starting_hp,player_hp_max,player_hp_remaining,enemy_hp_remaining,rounds")
	else:
		file.seek_end()
	var row = "%s,%s,%s,%d,%s,%d,%d,%d,%d,%d,%d,%d" % [
		summary["timestamp"],
		summary["outcome"],
		summary["enemy_name"],
		summary["enemy_level"],
		summary["enemy_archetype"],
		summary["player_atk"],
		summary["player_def"],
		summary["player_starting_hp"],
		summary["player_hp_max"],
		summary["player_hp_remaining"],
		summary["enemy_hp_remaining"],
		summary["rounds"],
	]
	file.store_line(row)
	file.close()
	_log("_log_combat_to_csv(): %s vs %s -> %s" % [summary["outcome"], summary["enemy_name"], path])

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): log daemon offline.")
