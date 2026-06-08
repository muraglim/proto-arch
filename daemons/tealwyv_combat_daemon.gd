#TODO: replace colloquial language in logs with machine-parsable prose. wait for appropriate stage of development.
class_name TealwyvCombatDaemon
extends Daemon

const CRIT_MULTIPLIER: float = 2.0

var luck_daemon: TealwyvLuckDaemon
var enemy: Dictionary = {}
var is_combat_active: bool = false
var _encounter_snapshot: Dictionary = {}

func daemon_init() -> void:
	luck_daemon = _get_sibling_daemon("tealwyv_luck_daemon")
	start_encounter()

func start_encounter() -> void:
	if luck_daemon == null: return
	_roll_encounter()

func _roll_encounter() -> void:
	var all_enemies: Array = Firm.get_value("tealwyv_forest_ledger", "enemies")
	var dev_level: int = Keeper.get_value("_dev_store", "enemy_level")
	var target_level: int = dev_level if dev_level > 0 else 1
	var pool: Array = all_enemies.filter(func(e): return e["level"] == target_level)
	enemy = pool[randi() % pool.size()].duplicate()
	enemy["hp"] = ceil(enemy["hp"])
	enemy["attack"] = floor(enemy["attack"])
	enemy["defense"] = floor(enemy["defense"])
	_encounter_snapshot = {
		"player_atk": Keeper.get_value("tealwyv_player_store", "attack"),
		"player_def": Keeper.get_value("tealwyv_player_store", "defense"),
		"player_hp_max": Keeper.get_value("tealwyv_player_store", "hp_max"),
	}
	is_combat_active = true
	# TODO create player naming step, then display it somewhere, likely appropriate for 'view player stats' feature
	var player_name = Keeper.get_value("tealwyv_player_store", "player_name")
	combat_update.emit("%s stands before you. HP: %d | ATK: %d | DEF: %d\n\nWhat do you do? [attack / run]" % [
		enemy["name"], enemy["hp"], enemy["attack"], enemy["defense"]
	])
	_log("_roll_encounter(): %s spawned." % enemy["name"])

func take_action(action: String) -> void:
	if not is_combat_active: return
	match action:
		"a":
			_resolve_turn()
		"r":
			_resolve_run()
		_:
			combat_update.emit("You hestitate. [a]ttack/[r]un")

func _resolve_turn() -> void:
	var result_lines: Array = []

	# player attacks
	var damage_to_enemy: int = 0
	if luck_daemon.proc_miss_mob():
		result_lines.append("The %s stumbles — your attack misses." % enemy["name"])
	else:
		var player_attack = Keeper.get_value("tealwyv_player_store", "attack")
		var is_crit = luck_daemon.proc_crit()
		damage_to_enemy = _apply_defense(player_attack, enemy["defense"])
		if is_crit:
			damage_to_enemy = int(damage_to_enemy * CRIT_MULTIPLIER)
			result_lines.append("Critical hit! You strike for %d damage." % damage_to_enemy)
		else:
			result_lines.append("You strike for %d damage." % damage_to_enemy)
		enemy["hp"] -= damage_to_enemy

	if enemy["hp"] <= 0:
		_resolve_victory(result_lines)
		return

		# enemy attacks
	if luck_daemon.proc_miss_player():
		result_lines.append("The %s swings wildly and misses." % enemy["name"])
	else:
		var enemy_damage = _apply_defense(enemy["attack"], Keeper.get_value("tealwyv_player_store", "defense"))
		result_lines.append("The %s hits you for %d damage." % [enemy["name"], enemy_damage])
		offset_value("tealwyv_player_store", "hp", -float(enemy_damage))

	var player_hp = Keeper.get_value("tealwyv_player_store", "hp")
	if player_hp <= 0:
		_resolve_defeat(result_lines)
		return

	result_lines.append("\n%s HP: %d | Your HP: %d\n\n[attack / run]" % [
		enemy["name"], enemy["hp"], player_hp
	])
	combat_update.emit("\n".join(result_lines))

func _resolve_run() -> void:
	var run_chance = 0.4
	if randf() < run_chance:
		is_combat_active = false
		luck_daemon.diminish()
		combat_update.emit("You slip away into the trees.\n\n[look for fight / return to town]")
		_log("_resolve_run(): player escaped.")
	else:
		var enemy_damage = max(0, enemy["attack"] - Keeper.get_value("tealwyv_player_store", "defense"))
		offset_value("tealwyv_player_store", "hp", -float(enemy_damage))
		var player_hp = Keeper.get_value("tealwyv_player_store", "hp")
		if player_hp <= 0:
			_resolve_defeat(["You fail to escape. The %s cuts you down." % enemy["name"]])
			return
		combat_update.emit("You fail to escape. The %s hits you for %d damage.\nYour HP: %d\n\n[attack / run]" % [
			enemy["name"], enemy_damage, player_hp
		])

func _apply_defense(raw_damage: int, defense: float) -> int:
	var factor = 1.0 - (0.06 * defense) / (1.0 + 0.06 * abs(defense))
	return max(1, int(raw_damage * factor))

func _resolve_victory(lines: Array) -> void:
	is_combat_active = false
	var exp_gain = enemy["exp"]
	var gold_gain = enemy["gold"]
	offset_value("tealwyv_player_store", "experience", float(exp_gain))
	offset_value("tealwyv_player_store", "gold", float(gold_gain))
	luck_daemon.diminish()
	var player_hp_remaining = Keeper.get_value("tealwyv_player_store", "hp")
	_write_encounter_result("victory", player_hp_remaining, 0)
	lines.append("\nThe %s falls.\n\nYou gain %d experience and %d gold.\n\n[look for fight / return to town]" % [
		enemy["name"], exp_gain, gold_gain
	])
	combat_update.emit("\n".join(lines))
	_log("_resolve_victory(): %s defeated." % enemy["name"])

func _resolve_defeat(lines: Array) -> void:
	is_combat_active = false
	var hp_max = Keeper.get_value("tealwyv_player_store", "hp_max")
	var enemy_hp_remaining = enemy["hp"]
	Keeper.set_value("tealwyv_player_store", "hp", hp_max)
	luck_daemon.diminish()
	_write_encounter_result("defeat", 0, enemy_hp_remaining)
	lines.append("\nYou have been defeated.\n\n[continue]")
	combat_update.emit("\n".join(lines))
	_log("_resolve_defeat(): player defeated.")

func _get_sibling_daemon(daemon_name: String) -> Node:
	var under = get_parent()
	for child in under.get_children():
		if child.name == daemon_name:
			return child
	push_error("[%s] _get_sibling_daemon(): %s not found in under." % [name, daemon_name])
	return null

func _write_encounter_result(outcome: String, player_hp_remaining: float, enemy_hp_remaining: float) -> void:
	var path = "user://tealwyv_encounter_log.csv"
	var write_header = not FileAccess.file_exists(path)
	var file = FileAccess.open(path, FileAccess.READ_WRITE if not write_header else FileAccess.WRITE)
	if file == null:
		push_error("[tealwyv_combat_daemon] _write_encounter_result(): could not open %s" % path)
		return
	if write_header:
		file.store_line("timestamp,enemy_name,enemy_level,enemy_archetype,player_atk,player_def,player_hp_max,outcome,player_hp_remaining,enemy_hp_remaining")
	else:
		file.seek_end()
	var archetype = "_".join(enemy["name"].split("_").slice(1))
	var row = "%s,%s,%d,%s,%d,%d,%d,%s,%d,%d" % [
		Time.get_datetime_string_from_system(),
		enemy["name"],
		enemy["level"],
		archetype,
		_encounter_snapshot["player_atk"],
		_encounter_snapshot["player_def"],
		_encounter_snapshot["player_hp_max"],
		outcome,
		player_hp_remaining,
		enemy_hp_remaining
	]
	file.store_line(row)
	file.close()
	_log("_write_encounter_result(): logged %s vs %s -> %s" % [outcome, enemy["name"], path])
	
func daemon_shutdown() -> void:
	_log("daemon_shutdown(): combat daemon offline.")

@warning_ignore("unused_signal")
signal combat_update(text: String)
