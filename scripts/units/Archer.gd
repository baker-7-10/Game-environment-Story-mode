extends "res://scripts/units/Unit.gd"

var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

func do_attack() -> void:
	if not target or not is_instance_valid(target):
		return
	var p = projectile_scene.instantiate()
	p.global_position = global_position + Vector2(look_direction * 20, -10)
	p.target = target
	p.damage = _stat("damage", 15.0)
	p.team = team
	get_tree().current_scene.add_child(p)
