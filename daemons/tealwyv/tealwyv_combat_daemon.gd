#TODO: replace colloquial language in logs with machine-parsable prose. wait for appropriate stage of development.
class_name TealwyvCombatDaemon
extends TealwyvDaemon

enum EncounterState { INACTIVE, ACTIVE, RESOLUTION }
enum EncounterOutcome { VICTORY, DEFEAT, RUN }

var _luck_daemon: TealwyvLuckDaemon = null
var _enemy: Dictionary = {}
var _encounter_state: EncounterState = EncounterState.INACTIVE
var _encounter_snapshot: Dictionary = {}
var _round_count: int = 0
var _player_hp: float = 0.0

func wire_to_channel(channel: Channel) -> void:
	var forest = channel as TealwyvForestChannel
	if forest == null:
		push_error("[TealwyvCombatDaemon] wire_to_channel(): unexpected Channel type.")
		return
	forest.register_combat_daemon(self)

func wire_to_luck_daemon(daemon: TealwyvLuckDaemon) -> void:
	_luck_daemon = daemon

func daemon_init() -> void:
	pass
# start_encounter() is now called explicitly by the channel on player input
# daemon_init() no longer triggers combat - daemon stays resident, resets per encounter

func start_encounter() -> void:
	_round_count = 0
	_enemy = {}
	_encounter_state = EncounterState.INACTIVE
	_encounter_snapshot = {}
	if _luck_daemon == null:
		push_error("[TealwyvCombatDaemon] start_encounter(): no luck daemon.")
		return
	_roll_encounter()

func _roll_encounter() -> void:
	var all_enemies: Array = Firm.get_value("tealwyv_combat_ledger", "enemies")
	var dev_level: int = Keeper.get_value("_dev_store", "enemy_level")
	var target_level: int = dev_level if dev_level > 0 else 1
	var pool: Array = all_enemies.filter(func(e): return e["level"] == target_level)
	_enemy = pool[randi() % pool.size()].duplicate()
	_enemy["hp"] = ceil(_enemy["hp"])
	_enemy["attack"] = floor(_enemy["attack"])
	_enemy["defense"] = floor(_enemy["defense"])
	_encounter_snapshot = {
		"player_atk": get_character_value("attack"),
		"player_def": get_character_value("defense"),
		"player_hp_max": get_character_value("hp_max"),
	}
	_player_hp = get_character_value("hp")
	_encounter_state = EncounterState.ACTIVE
	combat_event.emit({"text": "%s stands before you. HP: %d | ATK: %d | DEF: %d\n\nWhat do you do? [attack / run]" % [_enemy["name"], _enemy["hp"], _enemy["attack"], _enemy["defense"]]})
	_log("_roll_encounter(): %s spawned." % _enemy["name"])

func take_action(action: String) -> void:
	if _encounter_state != EncounterState.ACTIVE: return
	match action:
		"a":
			_resolve_turn()
		"r":
			_resolve_run()
		_:
			combat_event.emit({"text":"You hestitate. [a]ttack/[r]un"})

func _resolve_turn() -> void:
	_round_count += 1
	var result_lines: Array = []
	# player attacks
	var damage_to_enemy: int = 0
	if _luck_daemon.proc_miss_mob():
		result_lines.append("The %s stumbles — your attack misses." % _enemy["name"])
	else:
		var player_attack = get_character_value("attack")
		var is_crit = _luck_daemon.proc_crit()
		damage_to_enemy = _apply_defense(player_attack, _enemy["defense"])
		if is_crit:
			damage_to_enemy = int(damage_to_enemy * get_combat_const("crit_multiplier"))
			result_lines.append("Critical hit! You strike for %d damage." % damage_to_enemy)
		else:
			result_lines.append("You strike for %d damage." % damage_to_enemy)
		_enemy["hp"] -= damage_to_enemy

	if _enemy["hp"] <= 0:
		_resolve_victory(result_lines)
		return

	# enemy attacks
	if _luck_daemon.proc_miss_player():
		result_lines.append("The %s swings wildly and misses." % _enemy["name"])
	else:
		var enemy_damage = _apply_defense(_enemy["attack"], get_character_value("defense"))
		result_lines.append("The %s hits you for %d damage." % [_enemy["name"], enemy_damage])
		_player_hp -= float(enemy_damage)

	if _player_hp <= 0:
		_resolve_defeat(result_lines)
		return

	result_lines.append("\n%s HP: %d | Your HP: %d\n\n[attack / run]" % [
		_enemy["name"], _enemy["hp"], _player_hp
	])
	combat_event.emit({"text":"\n".join(result_lines)})

func _resolve_run() -> void:
	if randf() < get_combat_const("run_chance"):
		_encounter_state = EncounterState.RESOLUTION
		_luck_daemon.diminish()
		_write_encounter_result(EncounterOutcome.RUN, _player_hp, _enemy["hp"])
		combat_event.emit({"text":"You slip away into the trees.\n\n[look for fight / return to town]", "state": EncounterState.RESOLUTION})
		_log("_resolve_run(): player escaped.")
	else:
		var enemy_damage = _apply_defense(_enemy["attack"], get_character_value("defense"))
		_player_hp -= float(enemy_damage)
		if _player_hp <= 0:
			_resolve_defeat(["You fail to escape. The %s cuts you down." % _enemy["name"]])
			return
		combat_event.emit({"text":"You fail to escape. The %s hits you for %d damage.\nYour HP: %d\n\n[attack / run]" % [_enemy["name"], enemy_damage, _player_hp], "state": EncounterState.RESOLUTION})

func _apply_defense(raw_damage: int, defense: float) -> int:
	var mitigation = get_combat_const("defense_mitigation")
	var factor = 1.0 - (mitigation * defense) / (1.0 + mitigation * abs(defense))
	return max(1, int(raw_damage * factor))

func _resolve_victory(lines: Array) -> void:
	_encounter_state = EncounterState.RESOLUTION
	var exp_gain = _enemy["exp"]
	var gold_gain = _enemy["gold"]
	offset_character_value("experience", float(exp_gain))
	offset_character_value("gold", float(gold_gain))
	_luck_daemon.diminish()
	_write_encounter_result(EncounterOutcome.VICTORY, _player_hp, 0)
	heal_full_hp()
	lines.append("\nThe %s falls.\n\nYou gain %d experience and %d gold.\n\n[look for fight / return to town]" % [
		_enemy["name"], exp_gain, gold_gain
	])
	combat_event.emit({"text":"\n".join(lines), "state": EncounterState.RESOLUTION})
	_log("_resolve_victory(): %s defeated." % _enemy["name"])

func _resolve_defeat(lines: Array) -> void:
	_encounter_state = EncounterState.RESOLUTION
	var enemy_hp_remaining = _enemy["hp"]
	heal_full_hp()
	_luck_daemon.diminish()
	_write_encounter_result(EncounterOutcome.DEFEAT, _player_hp, enemy_hp_remaining)
	lines.append("\nYou have been defeated.\n\n[continue]")
	combat_event.emit({"text":"\n".join(lines), "state": EncounterState.RESOLUTION})
	_log("_resolve_defeat(): player defeated.")

func _write_encounter_result(outcome: EncounterOutcome, player_hp_remaining: float, enemy_hp_remaining: float) -> void:
	var outcome_str: String = ""
	match outcome:
		EncounterOutcome.VICTORY: outcome_str = "VICTORY"
		EncounterOutcome.DEFEAT: outcome_str = "DEFEAT"
		EncounterOutcome.RUN: outcome_str = "RUN"
	var path = "user://tealwyv_encounter_log.csv"
	var write_header = not FileAccess.file_exists(path)
	var file = FileAccess.open(path, FileAccess.READ_WRITE if not write_header else FileAccess.WRITE)
	if file == null:
		push_error("[tealwyv_combat_daemon] _write_encounter_result(): could not open %s" % path)
		return
	if write_header:
		file.store_line("timestamp,enemy_name,enemy_level,enemy_archetype,player_atk,player_def,player_hp_max,outcome,player_hp_remaining,enemy_hp_remaining,rounds")
	else:
		file.seek_end()
	var archetype = "_".join(_enemy["name"].split("_").slice(1))
	var row = "%s,%s,%d,%s,%d,%d,%d,%s,%d,%d,%d" % [
		Time.get_datetime_string_from_system(),
		_enemy["name"],
		_enemy["level"],
		archetype,
		_encounter_snapshot["player_atk"],
		_encounter_snapshot["player_def"],
		_encounter_snapshot["player_hp_max"],
		outcome_str,
		player_hp_remaining,
		enemy_hp_remaining,
		_round_count
	]
	file.store_line(row)
	file.close()
	_log("_write_encounter_result(): logged %s vs %s -> %s" % [outcome_str, _enemy["name"], path])
	
func daemon_shutdown() -> void:
	_log("daemon_shutdown(): combat daemon offline.")

@warning_ignore("unused_signal")
signal combat_event(text: Dictionary)
