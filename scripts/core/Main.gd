extends Node2D

var unit_scenes: Dictionary = {}
var player_spawn_point: Marker2D
var enemy_spawn_point: Marker2D
var player_units_container: Node2D
var enemy_units_container: Node2D
var projectiles_container: Node2D

@onready var world: Node2D = $World
@onready var enemy_ai: Node = $EnemyAI

func _ready() -> void:
	unit_scenes["swordsman"] = preload("res://scenes/Swordsman.tscn")
	unit_scenes["archer"] = preload("res://scenes/Archer.tscn")
	unit_scenes["miner"] = preload("res://scenes/Miner.tscn")
	unit_scenes["heavy"] = preload("res://scenes/Heavy.tscn")
	unit_scenes["fast"] = preload("res://scenes/Fast.tscn")

	player_spawn_point = $World/PlayerSpawn
	enemy_spawn_point = $World/EnemySpawn
	player_units_container = $World/PlayerUnits
	enemy_units_container = $World/EnemyUnits
	projectiles_container = $World/Projectiles

	SignalBus.unit_spawned.connect(_on_unit_spawned)
	SignalBus.unit_died.connect(_on_unit_died)
	SignalBus.game_restarted.connect(_on_game_restarted)

	# Reload mission (SceneManager may have just set pending_mission_id)
	Global.load_current_mission()

	# Apply mission parameters
	var mission = Global.get_mission()
	if mission:
		if "starting_gold_player" in mission:
			Global.modify_gold(Global.PLAYER_TEAM, mission.starting_gold_player)
		if "starting_gold_enemy" in mission:
			Global.modify_gold(Global.ENEMY_TEAM, mission.starting_gold_enemy)
		enemy_ai.configure_from_mission(mission)
	else:
		# Fallback defaults
		Global.modify_gold(Global.PLAYER_TEAM, 300)
		Global.modify_gold(Global.ENEMY_TEAM, 300)

func _on_unit_spawned(team: int, _unit_ref: Node2D, type: String) -> void:
	var scene = unit_scenes.get(type)
	if not scene:
		return

	var unit = scene.instantiate()
	unit.team = team
	unit.unit_type = type

	var spawn_pos: Vector2
	var container: Node2D
	if team == Global.PLAYER_TEAM:
		spawn_pos = player_spawn_point.global_position
		container = player_units_container
		unit.look_direction = 1.0
	else:
		spawn_pos = enemy_spawn_point.global_position
		container = enemy_units_container
		unit.look_direction = -1.0

	unit.global_position = spawn_pos
	container.add_child(unit)

	if type != "miner":
		var idx = container.get_child_count() - 1
		var lane = idx % 5
		unit.global_position += Vector2(
			(randi() % 5) - 2,
			(lane - 2) * 10 + (randi() % 5) - 2
		)

	Global.modify_population(team, 1)

func _on_unit_died(team: int, _unit: Node2D) -> void:
	Global.modify_population(team, -1)

func _on_game_restarted() -> void:
	for child in player_units_container.get_children():
		child.queue_free()
	for child in enemy_units_container.get_children():
		child.queue_free()
