extends Area2D

var target: Node2D
var damage: float
var team: int
var speed: float = 400.0

var _spark_scene = preload("res://scenes/HitSpark.tscn")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var dir = (target.global_position - global_position).normalized()
	global_position += dir * speed * delta

	var dist = global_position.distance_to(target.global_position)
	if dist < 10.0:
		_on_hit_target()

func _on_body_entered(body: Node2D) -> void:
	var is_target = (body == target)
	var is_enemy = body.has_method("get_team") and body.get_team() != team
	if is_target or is_enemy:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		var is_kill = body.has_method("is_dead") and body.is_dead() if is_instance_valid(body) else false
		Global.apply_hit_stop(0.08 if is_kill else 0.04)
		_spawn_spark(global_position, Color(0.9, 0.85, 0.7))
		var sound_mgr = _get_sound_manager()
		if sound_mgr and sound_mgr.has_method("play_hit"):
			sound_mgr.play_hit(global_position)
		queue_free()

func _on_hit_target() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)
		var is_kill = target.is_dead() if target.has_method("is_dead") else false
		Global.apply_hit_stop(0.08 if is_kill else 0.04)
		_spawn_spark(global_position, Color(0.9, 0.85, 0.7))
		var sound_mgr = _get_sound_manager()
		if sound_mgr and sound_mgr.has_method("play_hit"):
			sound_mgr.play_hit(global_position)
	queue_free()

func _spawn_spark(at: Vector2, spark_color: Color = Color(1, 0.9, 0.5)) -> void:
	var spark = _spark_scene.instantiate()
	spark.global_position = at
	spark.color = spark_color
	spark.finished.connect(spark.queue_free)
	get_tree().current_scene.add_child(spark)

func _get_sound_manager() -> Node:
	var root = get_tree().current_scene
	return root.get_node("SoundManager") if root else null
