extends Button
class_name SpawnButton

@export var unit_type: String = "swordsman"
@export var unit_cost: int = 100

func _ready() -> void:
	pressed.connect(_on_pressed)

func _process(_delta: float) -> void:
	var can_afford = Global.get_gold(Global.PLAYER_TEAM) >= unit_cost
	disabled = not can_afford
	modulate = Color.WHITE if can_afford else Color(0.4, 0.4, 0.4, 0.6)

func _on_pressed() -> void:
	if Global.get_gold(Global.PLAYER_TEAM) >= unit_cost:
		Global.modify_gold(Global.PLAYER_TEAM, -unit_cost)
		SignalBus.unit_spawned.emit(Global.PLAYER_TEAM, null, unit_type)
