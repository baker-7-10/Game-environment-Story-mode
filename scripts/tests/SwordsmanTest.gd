extends Node2D

var swordsman_scene = preload("res://scenes/Swordsman.tscn")
var player_units: Array = []
var enemy_units: Array = []

@onready var camera: Camera2D = $Camera2D
@onready var ui: CanvasLayer = $UI
@onready var player_container: Node2D = $PlayerUnits
@onready var enemy_container: Node2D = $EnemyUnits
@onready var info_label: Label = $UI/InfoLabel
@onready var player_hp_label: Label = $UI/PlayerHP
@onready var enemy_hp_label: Label = $UI/EnemyHP

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: spawn_player()
			KEY_2: spawn_enemy()
			KEY_3: spawn_1v1()
			KEY_A: set_stance_advance()
			KEY_H: set_stance_hold()
			KEY_R: set_stance_retreat()
			KEY_X: reset_test()

func _ready() -> void:
	Global.reset_match()
	Global.player_gold = 9999
	Global.enemy_gold = 9999
	Global.player_stance = Global.ArmyStance.ADVANCE
	_connect_buttons()
	_update_ui()
	# Auto-spawn 1v1 immediately
	await get_tree().create_timer(0.3).timeout
	spawn_player_at(Vector2(400, 360))
	spawn_enemy_at(Vector2(880, 360))

func _connect_buttons() -> void:
	$UI/SpawnPlayerBtn.pressed.connect(spawn_player)
	$UI/SpawnEnemyBtn.pressed.connect(spawn_enemy)
	$UI/SpawnWaveBtn.pressed.connect(spawn_1v1)
	$UI/AdvanceBtn.pressed.connect(set_stance_advance)
	$UI/HoldBtn.pressed.connect(set_stance_hold)
	$UI/RetreatBtn.pressed.connect(set_stance_retreat)
	$UI/ResetBtn.pressed.connect(reset_test)

func _process(_delta: float) -> void:
	_update_ui()
	_cleanup_dead(player_units)
	_cleanup_dead(enemy_units)

func _update_ui() -> void:
	if info_label:
		info_label.text = "Stance: " + _stance_name()
		info_label.text += "  |  Player: " + str(player_units.size())
		info_label.text += "  |  Enemy: " + str(enemy_units.size())
	if player_hp_label:
		var total_hp = 0.0
		var max_hp = 0.0
		for u in player_units:
			if is_instance_valid(u):
				total_hp += u.current_health
				max_hp += u._stat("max_health", 150.0)
		player_hp_label.text = "Player HP: " + str(int(total_hp)) + "/" + str(int(max_hp))
	if enemy_hp_label:
		var total_hp = 0.0
		var max_hp = 0.0
		for u in enemy_units:
			if is_instance_valid(u):
				total_hp += u.current_health
				max_hp += u._stat("max_health", 150.0)
		enemy_hp_label.text = "Enemy HP: " + str(int(total_hp)) + "/" + str(int(max_hp))

func _stance_name() -> String:
	match Global.player_stance:
		Global.ArmyStance.ADVANCE: return "ADVANCE"
		Global.ArmyStance.HOLD: return "HOLD"
		Global.ArmyStance.RETREAT: return "RETREAT"
	return "UNKNOWN"

func _cleanup_dead(arr: Array) -> void:
	for i in range(arr.size() - 1, -1, -1):
		if not is_instance_valid(arr[i]):
			arr.remove_at(i)

func spawn_player() -> void:
	var x_off = randf_range(-20, 20)
	var y_off = randf_range(-15, 15)
	spawn_player_at(Vector2(200 + x_off, 360 + y_off))

func spawn_enemy() -> void:
	var x_off = randf_range(-20, 20)
	var y_off = randf_range(-15, 15)
	spawn_enemy_at(Vector2(1080 + x_off, 360 + y_off))

func spawn_player_at(pos: Vector2) -> void:
	var unit = swordsman_scene.instantiate()
	unit.team = Global.PLAYER_TEAM
	unit.unit_type = "swordsman"
	unit.position = pos
	player_container.add_child(unit)
	player_units.append(unit)
	Global.modify_population(Global.PLAYER_TEAM, 1)

func spawn_enemy_at(pos: Vector2) -> void:
	var unit = swordsman_scene.instantiate()
	unit.team = Global.ENEMY_TEAM
	unit.unit_type = "swordsman"
	unit.position = pos
	enemy_container.add_child(unit)
	enemy_units.append(unit)
	Global.modify_population(Global.ENEMY_TEAM, 1)

func spawn_wave(count: int) -> void:
	for i in count:
		spawn_player()
		spawn_enemy()

func spawn_1v1() -> void:
	spawn_player_at(Vector2(randf_range(350, 450), 360))
	spawn_enemy_at(Vector2(randf_range(830, 930), 360))

func set_stance_advance() -> void:
	Global.player_stance = Global.ArmyStance.ADVANCE
	SignalBus.army_stance_changed.emit(Global.player_stance)

func set_stance_hold() -> void:
	Global.player_stance = Global.ArmyStance.HOLD
	SignalBus.army_stance_changed.emit(Global.player_stance)

func set_stance_retreat() -> void:
	Global.player_stance = Global.ArmyStance.RETREAT
	SignalBus.army_stance_changed.emit(Global.player_stance)

func reset_test() -> void:
	for u in player_units:
		if is_instance_valid(u):
			u.queue_free()
	for u in enemy_units:
		if is_instance_valid(u):
			u.queue_free()
	player_units.clear()
	enemy_units.clear()
	Global.reset_match()
	Global.player_gold = 9999
	Global.enemy_gold = 9999
	Global.player_stance = Global.ArmyStance.ADVANCE

func _draw() -> void:
	draw_rect(Rect2(0, 300, 1280, 120), Color(0.18, 0.15, 0.12))
	draw_line(Vector2(0, 300), Vector2(1280, 300), Color(0.25, 0.22, 0.18), 2.0)
	draw_rect(Rect2(50, 280, 60, 40), Color(0.2, 0.5, 0.9, 0.6))
	draw_rect(Rect2(1170, 280, 60, 40), Color(0.9, 0.3, 0.2, 0.6))
	draw_string(ThemeDB.fallback_font, Vector2(60, 275), "PLAYER BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.5, 0.7, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(1175, 275), "ENEMY BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.5, 0.4))
