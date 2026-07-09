extends "res://scripts/units/Unit.gd"

func _ready() -> void:
	super._ready()
	visual.scale = Vector2(1.3, 1.3)

func do_attack() -> void:
	if target and is_instance_valid(target):
		apply_damage_to_target(_stat("damage", 30.0))
	var tween = create_tween()
	tween.tween_property(visual, "position:x", sign(look_direction) * 14, 0.06)
	tween.tween_property(visual, "position:x", 0, 0.12)
