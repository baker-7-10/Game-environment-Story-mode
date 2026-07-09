extends Unit

func _ready() -> void:
	super._ready()

func do_attack() -> void:
	if target and is_instance_valid(target):
		apply_damage_to_target(stats.damage)
	var tween = create_tween()
	tween.tween_property(visual, "position:x", sign(look_direction) * 10, 0.05)
	tween.tween_property(visual, "position:x", 0, 0.1)
