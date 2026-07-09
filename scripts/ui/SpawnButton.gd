extends Button

@export var unit_type: String = "swordsman"
@export var unit_cost: int = 100

var _effective_cost:
	get:
		return max(1, int(round(unit_cost * SaveManager.get_upgrade_mult_for(unit_type, "gold_cost"))))

func _ready() -> void:
	pressed.connect(_on_pressed)

@onready var _base_label: String = text.split(" $")[0]

func _process(_delta: float) -> void:
	var at_pop_cap = Global.get_population(Global.PLAYER_TEAM) >= Global.MAX_POPULATION
	var cost = _effective_cost
	disabled = at_pop_cap or Global.get_gold(Global.PLAYER_TEAM) < cost
	text = _base_label + " $" + str(cost)

func _on_pressed() -> void:
	if Global.get_population(Global.PLAYER_TEAM) >= Global.MAX_POPULATION:
		return
	var cost = _effective_cost
	if Global.get_gold(Global.PLAYER_TEAM) >= cost:
		Global.modify_gold(Global.PLAYER_TEAM, -cost)
		SignalBus.unit_spawned.emit(Global.PLAYER_TEAM, null, unit_type)
