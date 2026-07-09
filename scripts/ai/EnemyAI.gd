extends Node

@export var base_interval: float = 4.0
@export var min_interval: float = 1.2
@export var decay_rate: float = 0.02

var spawn_timer: float = 0.0

var weight_phases: Array = [
	[0.0,  0.7, 0.2, 0.1],
	[30.0, 0.4, 0.4, 0.2],
	[60.0, 0.2, 0.5, 0.3],
	[120.0, 0.1, 0.4, 0.5],
]

var _miner_stats: Resource
var _swordsman_stats: Resource
var _archer_stats: Resource

func _ready() -> void:
	_miner_stats = preload("res://resources/UnitStats/MinerStats.tres")
	_swordsman_stats = preload("res://resources/UnitStats/SwordsmanStats.tres")
	_archer_stats = preload("res://resources/UnitStats/ArcherStats.tres")

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
				lerp(phase[1], next_phase[1], lerp_factor),
				lerp(phase[2], next_phase[2], lerp_factor),
				lerp(phase[3], next_phase[3], lerp_factor),
			]
			break
	var last = weight_phases[weight_phases.size() - 1]
	if t >= last[0]:
		weights = last
	return weights

func _spawn_unit() -> void:
	var weights = _get_current_weights()
	var roll = randf()
	var total = weights[1] + weights[2] + weights[3]
	var type: String
	if roll < weights[1] / total:
		type = "miner"
	elif roll < (weights[1] + weights[2]) / total:
		type = "swordsman"
	else:
		type = "archer"

	var stats = _get_stats_for_type(type)
	var cost = stats.gold_cost if stats and "gold_cost" in stats else 999
	if stats and Global.get_gold(Global.ENEMY_TEAM) >= cost:
		Global.modify_gold(Global.ENEMY_TEAM, -cost)
		SignalBus.unit_spawned.emit(Global.ENEMY_TEAM, null, type)

func _get_stats_for_type(type: String) -> Resource:
	match type:
		"miner":
			return _miner_stats
		"swordsman":
			return _swordsman_stats
		"archer":
			return _archer_stats
	return null
