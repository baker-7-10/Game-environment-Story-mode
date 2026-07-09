extends Resource

@export var mission_id: int = 1
@export var mission_name: String = "Mission 1"
@export var description: String = ""
@export var starting_gold_player: int = 300
@export var starting_gold_enemy: int = 300
@export var enemy_base_interval: float = 4.0
@export var enemy_min_interval: float = 1.2
@export var enemy_decay_rate: float = 0.02
@export var enemy_weight_phases: Array = [
	[0.0,  0.7, 0.2, 0.1, 0.0, 0.0],
	[30.0, 0.4, 0.3, 0.2, 0.1, 0.0],
	[60.0, 0.2, 0.3, 0.2, 0.15, 0.15],
	[120.0, 0.1, 0.2, 0.25, 0.2, 0.25],
]
@export var reward_currency: int = 50
