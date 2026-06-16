class_name TealwyvCombatDaemon
extends TealwyvDaemon

enum EncounterState { INACTIVE, ACTIVE, RESOLUTION }
enum EncounterOutcome { VICTORY, DEFEAT, RUN }

var _luck_daemon: TealwyvLuckDaemon = null
var _reward_daemon: TealwyvRewardDaemon = null
var _enemy: Dictionary = {}
var _encounter_state: EncounterState = EncounterState.INACTIVE
var _player_snapshot: Dictionary = {}
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

func wire_to_reward_daemon(daemon: TealwyvRewardDaemon) -> void:
	_reward_daemon = daemon

func daemon_init() -> void:
	pass

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): combat daemon offline.")

# called by tealwyv_forest_channel
func start_encounter(enemy: Dictionary) -> void:
	_round_count = 0
	_enemy = enemy
	_encounter_state = EncounterState.INACTIVE
	_player_snapshot = {}
	if _luck_daemon == null:
		push_error("[TealwyvCombatDaemon] start_encounter(): no luck daemon.")
		return
	if _reward_daemon == null:
		push_error("[TealwyvCombatDaemon] start_encounter(): no reward daemon.")
		return
	_player_snapshot = {
		"player_atk": get_character_value("attack"),
		"player_def": get_character_value("defense"),
		"player_starting_hp": get_character_value("hp"),
		"player_hp_max": get_character_value("hp_max"),
	}
	_player_hp = get_character_value("hp")
	_encounter_state = EncounterState.ACTIVE
	combat_event.emit({"text": "%s stands before you. HP: %d | ATK: %d | DEF: %d\n\nWhat do you do? [attack / run]" % [_enemy["name"], _enemy["hp"], _enemy["attack"], _enemy["defense"]]})
	_log("start_encounter(): %s spawned." % _enemy["name"])

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
	_resolve_player_attack(result_lines)
	if _enemy["hp"] <= 0:
		_resolve_victory(result_lines)
		return
	_resolve_enemy_attack(result_lines)
	if _player_hp <= 0:
		_resolve_defeat(result_lines)
		return
	result_lines.append("\n%s HP: %d | Your HP: %d\n\n[attack / run]" % [
		_enemy["name"], _enemy["hp"], _player_hp
	])
	combat_event.emit({"text":"\n".join(result_lines)})

func _resolve_player_attack(result_lines: Array) -> void:
	if _luck_daemon.proc_miss_mob():
		result_lines.append("The %s stumbles — your attack misses." % _enemy["name"])
		return
	var player_attack = get_character_value("attack")
	var is_crit = _luck_daemon.proc_crit()
	var damage_to_enemy = _apply_defense(player_attack, _enemy["defense"])
	if is_crit:
		damage_to_enemy = int(damage_to_enemy * get_combat_const("crit_multiplier"))
		result_lines.append("Critical hit! You strike for %d damage." % damage_to_enemy)
	else:
		result_lines.append("You strike for %d damage." % damage_to_enemy)
	_enemy["hp"] -= damage_to_enemy

func _resolve_enemy_attack(result_lines: Array) -> void:
	if _luck_daemon.proc_miss_player():
		result_lines.append("The %s swings wildly and misses." % _enemy["name"])
		return
	var enemy_damage = _apply_defense(_enemy["attack"], get_character_value("defense"))
	result_lines.append("The %s hits you for %d damage." % [_enemy["name"], enemy_damage])
	_player_hp -= float(enemy_damage)

func _apply_defense(raw_damage: int, defense: float) -> int:
	var mitigation = get_combat_const("defense_mitigation")
	var factor = 1.0 - (mitigation * defense) / (1.0 + mitigation * abs(defense))
	return max(1, int(raw_damage * factor))

func _resolve_victory(lines: Array) -> void:
	_encounter_state = EncounterState.RESOLUTION
	var reward = _reward_daemon.resolve_reward(_enemy)
	_luck_daemon.diminish()
	encounter_concluded.emit(_build_encounter_summary(EncounterOutcome.VICTORY, _player_hp, _enemy["hp"]))
	heal_full_hp()
	lines.append("\nThe %s falls.\n\nYou gain %d experience and %d gold.\n\n[look for fight / return to town]" % [
		_enemy["name"], reward["experience"], reward["gold"]
	])
	combat_event.emit({"text":"\n".join(lines), "state": EncounterState.RESOLUTION})
	_log("_resolve_victory(): %s defeated." % _enemy["name"])

func _resolve_defeat(lines: Array) -> void:
	_encounter_state = EncounterState.RESOLUTION
	var enemy_hp_remaining = _enemy["hp"]
	heal_full_hp()
	_luck_daemon.diminish()
	encounter_concluded.emit(_build_encounter_summary(EncounterOutcome.DEFEAT, _player_hp, enemy_hp_remaining))
	lines.append("\nYou have been defeated.\n\n[continue]")
	combat_event.emit({"text":"\n".join(lines), "state": EncounterState.RESOLUTION})
	_log("_resolve_defeat(): player defeated.")

func _resolve_run() -> void:
	if randf() < get_combat_const("run_chance"):
		_encounter_state = EncounterState.RESOLUTION
		_luck_daemon.diminish()
		encounter_concluded.emit(_build_encounter_summary(EncounterOutcome.RUN, _player_hp, _enemy["hp"]))
		combat_event.emit({"text":"You slip away into the trees.\n\n[look for fight / return to town]", "state": EncounterState.RESOLUTION})
		_log("_resolve_run(): player escaped.")
	else:
		var enemy_damage = _apply_defense(_enemy["attack"], get_character_value("defense"))
		_player_hp -= float(enemy_damage)
		if _player_hp <= 0:
			_resolve_defeat(["You fail to escape. The %s cuts you down." % _enemy["name"]])
			return
		combat_event.emit({"text":"You fail to escape. The %s hits you for %d damage.\nYour HP: %d\n\n[attack / run]" % [_enemy["name"], enemy_damage, _player_hp]})

func _build_encounter_summary(outcome: EncounterOutcome, player_hp_remaining: float, enemy_hp_remaining: float) -> Dictionary:
	var outcome_str: String = ""
	match outcome:
		EncounterOutcome.VICTORY: outcome_str = "VICTORY"
		EncounterOutcome.DEFEAT: outcome_str = "DEFEAT"
		EncounterOutcome.RUN: outcome_str = "RUN"
	return {
		"timestamp": Time.get_datetime_string_from_system(),
		"outcome": outcome_str,
		"enemy_name": _enemy["name"],
		"enemy_level": _enemy["level"],
		"enemy_archetype": "_".join(_enemy["name"].split("_").slice(1)),
		"player_atk": _player_snapshot["player_atk"],
		"player_def": _player_snapshot["player_def"],
		"player_starting_hp": _player_snapshot["player_starting_hp"],
		"player_hp_max": _player_snapshot["player_hp_max"],
		"player_hp_remaining": player_hp_remaining,
		"enemy_hp_remaining": enemy_hp_remaining,
		"rounds": _round_count,
	}

@warning_ignore("unused_signal")
signal combat_event(text: Dictionary)
@warning_ignore("unused_signal")
signal encounter_concluded(summary: Dictionary)
