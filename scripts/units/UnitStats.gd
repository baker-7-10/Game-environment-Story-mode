extends Resource
class_name UnitStats

# Data-only resource for unit balance tuning.
# Create .tres files to define new unit types — no code changes needed.

@export var unit_name: String = "Unit"
@export var max_health: float = 100.0
@export var damage: float = 10.0
@export var attack_speed: float = 1.0  # attacks per second
@export var move_speed: float = 100.0  # pixels per second
@export var attack_range: float = 50.0
@export var gold_cost: int = 100
@export var attack_cooldown: float = 1.0
