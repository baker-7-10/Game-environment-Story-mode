extends Node

var hero: Node2D = null

func select_hero(unit: Node2D) -> void:
	if hero and is_instance_valid(hero):
		release_hero()
	hero = unit
	hero.set_hero(true)

func release_hero() -> void:
	if hero and is_instance_valid(hero):
		hero.set_hero(false)
	hero = null

func has_hero() -> bool:
	return hero != null and is_instance_valid(hero) and not hero.is_dead()

func _unhandled_input(event: InputEvent) -> void:
	if not has_hero():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_hero_attack()

func _physics_process(_delta: float) -> void:
	if not has_hero():
		return

	var dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1

	if dir.length() > 0:
		dir = dir.normalized()
		hero.velocity = dir * hero._stat("move_speed", 100.0)
		hero.look_direction = sign(dir.x)
		hero.direct_control = true
		hero.move_and_slide()
	else:
		hero.direct_control = false

func _hero_attack() -> void:
	if not hero.can_attack():
		return
	hero.acquire_target()
	if hero.target:
		hero.look_direction = sign((hero.target.global_position - hero.global_position).x)
		hero.perform_attack()
