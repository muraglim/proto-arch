#TODO: replace colloquial language in logs with machine-parsable prose. wait for appropriate stage of development.
class_name TealwyvCombatDaemon
extends Daemon

const CRIT_MULTIPLIER: float = 2.0

var luck_daemon: TealwyvLuckDaemon
var enemy: Dictionary = {}
var is_combat_active: bool = false

func daemon_init() -> void:
	luck_daemon = _get_sibling_daemon("tealwyv_luck_daemon")
	start_encounter()

func start_encounter() -> void:
	if luck_daemon == null: return
	_roll_encounter()

func _roll_encounter() -> void:
	var all_enemies: Array = Firm.get_value("tealwyv_forest_ledger", "enemies")
	var pool: Array = all_enemies.filter(func(e): return e["level"] == 1)
	enemy = pool[randi() % pool.size()].duplicate()
	enemy["hp"] = ceil(enemy["hp"])
	enemy["attack"] = floor(enemy["attack"])
	enemy["defense"] = floor(enemy["defense"])
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
	lines.append("\nThe %s falls.\n\nYou gain %d experience and %d gold.\n\n[look for fight / return to town]" % [
		enemy["name"], exp_gain, gold_gain
	])
	combat_update.emit("\n".join(lines))
	_log("_resolve_victory(): %s defeated." % enemy["name"])

func _resolve_defeat(lines: Array) -> void:
	is_combat_active = false
	var hp_max = Keeper.get_value("tealwyv_player_store", "hp_max")
	Keeper.set_value("tealwyv_player_store", "hp", hp_max)
	luck_daemon.diminish()
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

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): combat daemon offline.")

@warning_ignore("unused_signal")
signal combat_update(text: String)
