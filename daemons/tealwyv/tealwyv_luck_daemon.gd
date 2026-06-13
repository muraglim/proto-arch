class_name TealwyvLuckDaemon
extends Daemon

const BASE_CRIT: float = 0.15
const BASE_MISS_PLAYER: float = 0.07
const BASE_MISS_MOB: float = 0.10
const DIMINISH_FACTOR: float = 0.25
var PRD_INITIAL: float = _solve_prd_initial(BASE_CRIT)

func wire_to_channel(channel: Channel) -> void:
	var forest = channel as TealwyvForestChannel
	if forest == null: return
	forest.register_luck_daemon(self)

static func _solve_prd_initial(p: float) -> float:
	var c: float = p / 10.0
	var step: float = c
	while true:
		var expected: float = _expected_proc_rate(c)
		if abs(expected - p) < 0.0001:
			break
		if expected < p:
			c += step
		else:
			c -= step
		step *= 0.5
	return c

static func _expected_proc_rate(c: float) -> float:
	var cumulative_no_proc: float = 1.0
	var expected_attacks: float = 0.0
	var n: int = 1
	var current_p: float = c
	while cumulative_no_proc > 0.0001:
		var p_proc_this = minf(current_p, 1.0) * cumulative_no_proc
		expected_attacks += n * p_proc_this
		cumulative_no_proc *= (1.0 - minf(current_p, 1.0))
		current_p += c
		n += 1
	return 1.0 / expected_attacks

func daemon_init() -> void:
	var current = Keeper.get_value("tealwyv_luck_store", "crit")
	if current == 0.0:
		Keeper.set_value("tealwyv_luck_store", "crit", PRD_INITIAL)
	_log("daemon_init(): luck daemon online. crit base: %s, prd initial: %s" % [BASE_CRIT, PRD_INITIAL])

func proc_crit() -> bool:
	var current = Keeper.get_value("tealwyv_luck_store", "crit")
	var roll = randf()
	if roll < current:
		Keeper.set_value("tealwyv_luck_store", "crit", PRD_INITIAL)
		_log("proc_crit(): CRIT — reset to %s" % PRD_INITIAL)
		return true
	var next = minf(current + PRD_INITIAL, 1.0)
	Keeper.set_value("tealwyv_luck_store", "crit", next)
	_log("proc_crit(): no crit — accumulated to %s" % next)
	return false

func proc_miss_player() -> bool:
	var result = randf() < BASE_MISS_PLAYER
	_log("proc_miss_player(): %s" % result)
	return result

func proc_miss_mob() -> bool:
	var result = randf() < BASE_MISS_MOB
	_log("proc_miss_mob(): %s" % result)
	return result

func diminish() -> void:
	var current = Keeper.get_value("tealwyv_luck_store", "crit")
	var diminished = maxf(current * (1.0 - DIMINISH_FACTOR), PRD_INITIAL)
	Keeper.set_value("tealwyv_luck_store", "crit", diminished)
	_log("diminish(): %s -> %s" % [current, diminished])

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): luck daemon offline.")
