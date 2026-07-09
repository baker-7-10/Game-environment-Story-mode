extends Node

# Global autoload singleton for cross-system match state.
# Central authority for gold, game-over state, and match time.
# No other system should mutate economy data directly — they must go through
# this singleton or SignalBus to keep the data flow traceable.

var match_time: float = 0.0
var is_game_over: bool = false
var winner: int = -1  # -1=none, 0=player, 1=enemy

# Team gold tracked here as single source of truth.
var player_gold: int = 0
var enemy_gold: int = 0

const PLAYER_TEAM: int = 0
const ENEMY_TEAM: int = 1

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not is_game_over:
		match_time += delta

func reset_match() -> void:
	match_time = 0.0
	is_game_over = false
	winner = -1
	player_gold = 0
	enemy_gold = 0

func get_gold(team: int) -> int:
	return player_gold if team == PLAYER_TEAM else enemy_gold

func modify_gold(team: int, amount: int) -> void:
	if team == PLAYER_TEAM:
		player_gold = max(0, player_gold + amount)
	else:
		enemy_gold = max(0, enemy_gold + amount)
	SignalBus.gold_changed.emit(team, get_gold(team))

func declare_game_over(winning_team: int) -> void:
	if is_game_over:
		return
	is_game_over = true
	winner = winning_team
	SignalBus.game_over.emit(winning_team)
