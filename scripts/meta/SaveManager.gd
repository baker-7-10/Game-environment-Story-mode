extends Node

const SAVE_PATH: String = "user://save.json"

const UNIT_TYPES: Array = ["swordsman", "archer", "miner", "heavy", "fast"]
const UPGRADE_STATS: Dictionary = {
	"swordsman": ["damage", "max_health", "gold_cost"],
	"archer": ["damage", "max_health", "gold_cost"],
	"miner": ["max_health", "gold_cost"],
	"heavy": ["damage", "max_health", "gold_cost"],
	"fast": ["damage", "max_health", "gold_cost"],
}

# Level → multiplier for each stat
const DAMAGE_MULTS: Array = [1.0, 1.1, 1.2, 1.35, 1.5, 1.7]
const HEALTH_MULTS: Array = [1.0, 1.12, 1.25, 1.4, 1.6, 1.8]
const COST_MULTS: Array = [1.0, 0.95, 0.9, 0.85, 0.8, 0.75]
const MAX_LEVEL: int = 5

var unlocked_missions: Array = [1]
var completed_missions: Array = []
var currency: int = 0
var upgrades: Dictionary = {}

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_reset_upgrades()
	_load()

func _reset_upgrades() -> void:
	upgrades = {}
	for t in UNIT_TYPES:
		upgrades[t] = {}
		for s in UPGRADE_STATS[t]:
			upgrades[t][s] = 0

# --- Public API ---

func is_mission_unlocked(id: int) -> bool:
	return id in unlocked_missions

func is_mission_completed(id: int) -> bool:
	return id in completed_missions

func complete_mission(id: int) -> void:
	if id not in completed_missions:
		completed_missions.append(id)
	if id + 1 not in unlocked_missions:
		unlocked_missions.append(id + 1)
	_save()

func add_currency(amount: int) -> void:
	currency += max(0, amount)
	_save()

func get_upgrade_level(unit_type: String, stat: String) -> int:
	if upgrades.has(unit_type) and upgrades[unit_type].has(stat):
		return upgrades[unit_type][stat]
	return 0

func get_upgrade_cost(unit_type: String, stat: String) -> int:
	var level = get_upgrade_level(unit_type, stat)
	if level >= MAX_LEVEL:
		return -1
	return (level + 1) * 50

func can_afford_upgrade(unit_type: String, stat: String) -> bool:
	var cost = get_upgrade_cost(unit_type, stat)
	return cost >= 0 and currency >= cost

func purchase_upgrade(unit_type: String, stat: String) -> bool:
	if not can_afford_upgrade(unit_type, stat):
		return false
	var cost = get_upgrade_cost(unit_type, stat)
	currency -= cost
	upgrades[unit_type][stat] += 1
	_save()
	return true

func get_upgrade_mult_for(unit_type: String, stat: String) -> float:
	var level = get_upgrade_level(unit_type, stat)
	match stat:
		"damage":
			return DAMAGE_MULTS[level]
		"max_health":
			return HEALTH_MULTS[level]
		"gold_cost":
			return COST_MULTS[level]
	return 1.0

# --- Save/load ---

func _save() -> void:
	var data = {
		"unlocked_missions": unlocked_missions,
		"completed_missions": completed_missions,
		"currency": currency,
		"upgrades": upgrades,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	var data = JSON.parse_string(text)
	if not data is Dictionary:
		return
	if data.has("unlocked_missions"):
		unlocked_missions = data["unlocked_missions"]
	if data.has("completed_missions"):
		completed_missions = data["completed_missions"]
	if data.has("currency"):
		currency = data["currency"]
	if data.has("upgrades"):
		for t in UNIT_TYPES:
			if data["upgrades"].has(t):
				for s in UPGRADE_STATS[t]:
					if data["upgrades"][t].has(s):
						upgrades[t][s] = data["upgrades"][t][s]

func reset_save() -> void:
	unlocked_missions = [1]
	completed_missions = []
	currency = 0
	_reset_upgrades()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
