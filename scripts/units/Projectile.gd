extends Area2D

var target: Node2D
var damage: float
var team: int
var speed: float = 400.0

@onready var visual: Polygon2D = $Visual

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
		queue_free()

func _on_hit_target() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)
	queue_free()
