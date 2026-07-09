extends CanvasLayer
class_name GameUI

@onready var gold_label: Label = $GoldLabel
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var winner_label: Label = $GameOverOverlay/WinnerLabel
@onready var restart_button: Button = $GameOverOverlay/RestartButton

func _ready() -> void:
	SignalBus.gold_changed.connect(_on_gold_changed)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.game_restarted.connect(_on_game_restarted)
	restart_button.pressed.connect(_on_restart_pressed)
	game_over_overlay.hide()

func _on_gold_changed(team: int, amount: int) -> void:
	if team == Global.PLAYER_TEAM:
		gold_label.text = "Gold: $" + str(amount)

func _on_game_over(winner: int) -> void:
	game_over_overlay.show()
	if winner == Global.PLAYER_TEAM:
		winner_label.text = "VICTORY!"
		winner_label.modulate = Color.GREEN
	else:
		winner_label.text = "DEFEAT"
		winner_label.modulate = Color.RED
	get_tree().paused = true

func _on_game_restarted() -> void:
	game_over_overlay.hide()
	get_tree().paused = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.reset_match()
	SignalBus.game_restarted.emit()
	get_tree().reload_current_scene()
