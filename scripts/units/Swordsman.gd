extends "res://scripts/units/Unit.gd"

func do_attack() -> void:
	if target and is_instance_valid(target):
		apply_damage_to_target(_stat("damage", 25.0))
	var tween = create_tween()
	tween.tween_property(visual, "position:x", sign(look_direction) * 10, 0.05)
	tween.tween_property(visual, "position:x", 0, 0.1)
