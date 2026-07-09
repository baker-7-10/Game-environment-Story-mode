extends Node

@export var base_interval: float = 4.0
@export var min_interval: float = 1.2
@export var decay_rate: float = 0.02

var spawn_timer: float = 0.0

# [time, miner, swordsman, archer, heavy, fast]
var weight_phases: Array = [
	[0.0,  0.7, 0.2, 0.1, 0.0, 0.0],
	[30.0, 0.4, 0.3, 0.2, 0.1, 0.0],
	[60.0, 0.2, 0.3, 0.2, 0.15, 0.15],
	[120.0, 0.1, 0.2, 0.25, 0.2, 0.25],
]

func configure_from_mission(mission: Resource) -> void:
	if not mission:
		return
	if "enemy_base_interval" in mission:
		base_interval = mission.enemy_base_interval
	if "enemy_min_interval" in mission:
		min_interval = mission.enemy_min_interval
	if "enemy_decay_rate" in mission:
		decay_rate = mission.enemy_decay_rate
	if "enemy_weight_phases" in mission and mission.enemy_weight_phases.size() > 0:
		weight_phases = mission.enemy_weight_phases.duplicate()

var _type_list: Array = ["miner", "swordsman", "archer", "heavy", "fast"]

var _miner_stats: Resource
var _swordsman_stats: Resource
var _archer_stats: Resource
var _heavy_stats: Resource
var _fast_stats: Resource

func _ready() -> void:
	_miner_stats = preload("res://resources/UnitStats/MinerStats.tres")
	_swordsman_stats = preload("res://resources/UnitStats/SwordsmanStats.tres")
	_archer_stats = preload("res://resources/UnitStats/ArcherStats.tres")
	_heavy_stats = preload("res://resources/UnitStats/HeavyStats.tres")
	_fast_stats = preload("res://resources/UnitStats/FastStats.tres")

func _process(delta: float) -> void:
	if Global.is_game_over:
		return

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = _get_current_interval()
		_spawn_unit()

func _get_current_interval() -> float:
	var t = Global.match_time
	var interval = base_interval - t * decay_rate
	return max(min_interval, interval)

func _get_current_weights() -> Array:
	var t = Global.match_time
	var weights = weight_phases[0]
	for i in range(weight_phases.size() - 1):
		var phase = weight_phases[i]
		var next_phase = weight_phases[i + 1]
		if t >= phase[0] and t < next_phase[0]:
			var lerp_factor = (t - phase[0]) / (next_phase[0] - phase[0])
			weights = [
				t,
				lerpf(phase[1], next_phase[1], lerp_factor),
				lerpf(phase[2], next_phase[2], lerp_factor),
				lerpf(phase[3], next_phase[3], lerp_factor),
				lerpf(phase[4], next_phase[4], lerp_factor),
				lerpf(phase[5], next_phase[5], lerp_factor),
			]
			break
	var last = weight_phases[weight_phases.size() - 1]
	if t >= last[0]:
		weights = last
	return weights

func _spawn_unit() -> void:
	if Global.get_population(Global.ENEMY_TEAM) >= Global.MAX_POPULATION:
		return

	var weights = _get_current_weights()
	var roll = randf()

	var total = 0.0
	for i in range(1, weights.size()):
		total += weights[i]
	if total <= 0.0:
		return

	var cumulative = 0.0
	var type = _type_list[0]
	for i in range(_type_list.size()):
		cumulative += weights[i + 1]
		if roll < cumulative / total:
			type = _type_list[i]
			break

	var stats = _get_stats_for_type(type)
	if stats and "gold_cost" in stats and Global.get_gold(Global.ENEMY_TEAM) >= stats.gold_cost:
		Global.modify_gold(Global.ENEMY_TEAM, -stats.gold_cost)
		SignalBus.unit_spawned.emit(Global.ENEMY_TEAM, null, type)

func _get_stats_for_type(type: String) -> Resource:
	match type:
		"miner":
			return _miner_stats
		"swordsman":
			return _swordsman_stats
		"archer":
			return _archer_stats
		"heavy":
			return _heavy_stats
		"fast":
			return _fast_stats
	return null
