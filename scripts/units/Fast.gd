extends "res://scripts/units/Unit.gd"

func _ready() -> void:
	super._ready()
	visual.scale = Vector2(0.85, 0.85)

func do_attack() -> void:
	var dmg = _stat("damage", 10.0)
	if target and is_instance_valid(target) and target.has_method("get_unit_type") and target.get_unit_type() == "archer":
		dmg *= 2.0
	if target and is_instance_valid(target):
		apply_damage_to_target(dmg)
	var tween = create_tween()
	tween.tween_property(visual, "position:x", sign(look_direction) * 6, 0.03)
	tween.tween_property(visual, "position:x", 0, 0.06)
