extends Node

enum ArmyStance { ADVANCE, HOLD, RETREAT }

var match_time: float = 0.0
var is_game_over: bool = false
var winner: int = -1

var player_gold: int = 0
var enemy_gold: int = 0
var player_stance: int = ArmyStance.ADVANCE

const PLAYER_TEAM: int = 0
const ENEMY_TEAM: int = 1

# --- Population cap ---
const MAX_POPULATION: int = 20
var player_population: int = 0
var enemy_population: int = 0

# --- Miner limits ---
const MAX_MINERS_PER_TEAM: int = 6
const MAX_MINERS_PER_MINE: int = 2
const MINE_COUNT: int = 3
var player_miner_count: int = 0
var enemy_miner_count: int = 0
var player_miners_at_mine: Array = [[], [], []]
var enemy_miners_at_mine: Array = [[], [], []]

# --- Rage meter ---
const RAGE_MAX: float = 100.0
const RAGE_FILL_RATE: float = 4.0
const RAGE_DURATION: float = 8.0
const RAGE_DAMAGE_MULT: float = 1.5
const RAGE_SPEED_MULT: float = 1.3
var player_rage: float = 0.0
var enemy_rage: float = 0.0

var _rage_active: bool = false
var _rage_team: int = -1
var _rage_time_left: float = 0.0

var _hit_stop_remaining: float = 0.0

var current_mission: Resource = null

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	load_current_mission()

func load_current_mission() -> void:
	var id = SceneManager.pending_mission_id
	if id > 0:
		var path = "res://resources/Missions/Mission" + str(id) + ".tres"
		current_mission = load(path)
	else:
		current_mission = null

func get_mission() -> Resource:
	return current_mission

func _process(delta: float) -> void:
	if not is_game_over:
		match_time += delta

	if _hit_stop_remaining > 0.0 and Engine.time_scale < 1.0:
		var real_delta = delta / max(Engine.time_scale, 0.001)
		_hit_stop_remaining -= real_delta
		if _hit_stop_remaining <= 0.0:
			_hit_stop_remaining = 0.0
			Engine.time_scale = 1.0

	if not is_game_over:
		_tick_rage(delta)

func apply_hit_stop(duration: float) -> void:
	if _hit_stop_remaining < duration:
		_hit_stop_remaining = duration
	Engine.time_scale = 0.02

# ---------------------------------------------------------------------------
# Population
# ---------------------------------------------------------------------------
func get_population(team: int) -> int:
	return player_population if team == PLAYER_TEAM else enemy_population

func modify_population(team: int, delta: int) -> void:
	if team == PLAYER_TEAM:
		player_population = max(0, player_population + delta)
	else:
		enemy_population = max(0, enemy_population + delta)
	SignalBus.population_changed.emit(team, get_population(team), MAX_POPULATION)

# ---------------------------------------------------------------------------
# Rage
# ---------------------------------------------------------------------------
func is_rage_active(team: int) -> bool:
	return _rage_active and _rage_team == team

func get_rage_time_remaining() -> float:
	return _rage_time_left if _rage_active else 0.0

func activate_rage(team: int) -> void:
	if _rage_active:
		return
	_rage_active = true
	_rage_team = team
	_rage_time_left = RAGE_DURATION
	if team == PLAYER_TEAM:
		player_rage = 0.0
	else:
		enemy_rage = 0.0
	SignalBus.rage_changed.emit(team, 0.0, RAGE_MAX)
	SignalBus.rage_activated.emit(team, RAGE_DURATION)

func _tick_rage(delta: float) -> void:
	if _rage_active:
		_rage_time_left -= delta
		if _rage_time_left <= 0.0:
			_rage_active = false
			SignalBus.rage_deactivated.emit(_rage_team)
			_rage_team = -1
		return

	if player_rage < RAGE_MAX:
		player_rage = min(RAGE_MAX, player_rage + RAGE_FILL_RATE * delta)
		SignalBus.rage_changed.emit(PLAYER_TEAM, player_rage, RAGE_MAX)

func get_miner_count(team: int) -> int:
	return player_miner_count if team == PLAYER_TEAM else enemy_miner_count

func modify_miner_count(team: int, delta: int) -> void:
	if team == PLAYER_TEAM:
		player_miner_count = max(0, player_miner_count + delta)
	else:
		enemy_miner_count = max(0, enemy_miner_count + delta)

func get_miners_at_mine(team: int, mine_index: int = 0) -> Array:
	var arr = player_miners_at_mine if team == PLAYER_TEAM else enemy_miners_at_mine
	if mine_index < arr.size():
		return arr[mine_index]
	return []

func get_miners_at_mine_count(team: int, mine_index: int) -> int:
	return get_miners_at_mine(team, mine_index).size()

func get_nearest_available_mine(team: int, from_pos: Vector2) -> int:
	var positions = [Vector2(300, 260), Vector2(300, 360), Vector2(300, 460)] if team == PLAYER_TEAM else [Vector2(980, 260), Vector2(980, 360), Vector2(980, 460)]
	var best_idx = -1
	var best_dist = INF
	for idx in range(MINE_COUNT):
		if get_miners_at_mine_count(team, idx) < MAX_MINERS_PER_MINE:
			var d = from_pos.distance_squared_to(positions[idx])
			if d < best_dist:
				best_dist = d
				best_idx = idx
	return best_idx

func reset_match() -> void:
	match_time = 0.0
	is_game_over = false
	winner = -1
	player_gold = 0
	enemy_gold = 0
	player_stance = ArmyStance.ADVANCE
	player_population = 0
	enemy_population = 0
	player_miner_count = 0
	enemy_miner_count = 0
	player_miners_at_mine = [[], [], []]
	enemy_miners_at_mine = [[], [], []]
	player_rage = 0.0
	enemy_rage = 0.0
	_rage_active = false
	_rage_team = -1
	_rage_time_left = 0.0
	_hit_stop_remaining = 0.0
	Engine.time_scale = 1.0

func get_gold(team: int) -> int:
	return player_gold if team == PLAYER_TEAM else enemy_gold

func modify_gold(team: int, amount: int) -> void:
	if team == PLAYER_TEAM:
		player_gold = max(0, player_gold + amount)
	else:
		enemy_gold = max(0, enemy_gold + amount)
	SignalBus.gold_changed.emit(team, get_gold(team))

func declare_game_over(winning_team: int) -> void:
	if is_game_over:
		return
	is_game_over = true
	winner = winning_team
	SignalBus.game_over.emit(winning_team)
