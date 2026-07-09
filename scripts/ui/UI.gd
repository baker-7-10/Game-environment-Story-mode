extends CanvasLayer

@onready var gold_label: Label = $TopPanel/GoldLabel
@onready var pop_label: Label = $TopPanel/PopLabel
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var winner_label: Label = $GameOverOverlay/WinnerLabel
@onready var restart_button: Button = $GameOverOverlay/RestartButton
@onready var level_select_button: Button = $GameOverOverlay/LevelSelectButton
@onready var shop_button: Button = $GameOverOverlay/ShopButton

@onready var advance_btn: Button = $TopPanel/AdvanceButton
@onready var hold_btn: Button = $TopPanel/HoldButton
@onready var retreat_btn: Button = $TopPanel/RetreatButton

@onready var rage_bar_fill: ColorRect = $TopPanel/RageContainer/RageBarFill
@onready var rage_button: Button = $TopPanel/RageButton

var stance_buttons: Array[Button]
var _stance_active_style: StyleBoxFlat
var _stance_inactive_style: StyleBoxFlat

func _make_stance_style(active: bool) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	if active:
		s.bg_color = Color(0.2, 0.35, 0.55)
		s.border_color = Color(0.4, 0.6, 0.85)
	else:
		s.bg_color = Color(0.12, 0.14, 0.22)
		s.border_color = Color(0.2, 0.25, 0.35)
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_right = 6
	s.corner_radius_bottom_left = 6
	s.border_width_left = 1
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	return s

func _ready() -> void:
	_stance_active_style = _make_stance_style(true)
	_stance_inactive_style = _make_stance_style(false)

	SignalBus.gold_changed.connect(_on_gold_changed)
	SignalBus.population_changed.connect(_on_population_changed)
	SignalBus.rage_changed.connect(_on_rage_changed)
	SignalBus.rage_activated.connect(_on_rage_activated)
	SignalBus.rage_deactivated.connect(_on_rage_deactivated)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.game_restarted.connect(_on_game_restarted)
	restart_button.pressed.connect(_on_restart_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	rage_button.pressed.connect(_on_rage_pressed)
	game_over_overlay.hide()

	stance_buttons = [advance_btn, hold_btn, retreat_btn]
	advance_btn.pressed.connect(_on_stance_pressed.bind(Global.ArmyStance.ADVANCE, advance_btn))
	hold_btn.pressed.connect(_on_stance_pressed.bind(Global.ArmyStance.HOLD, hold_btn))
	retreat_btn.pressed.connect(_on_stance_pressed.bind(Global.ArmyStance.RETREAT, retreat_btn))

	_highlight_stance(Global.ArmyStance.ADVANCE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q: _set_stance(Global.ArmyStance.ADVANCE, advance_btn)
			KEY_W: _set_stance(Global.ArmyStance.HOLD, hold_btn)
			KEY_E: _set_stance(Global.ArmyStance.RETREAT, retreat_btn)
			KEY_R: _on_rage_pressed()

func _set_stance(stance: int, btn: Button) -> void:
	if Global.is_game_over:
		return
	Global.player_stance = stance
	SignalBus.army_stance_changed.emit(stance)
	_highlight_stance(stance)

func _on_stance_pressed(stance: int, btn: Button) -> void:
	_set_stance(stance, btn)

func _highlight_stance(active: int) -> void:
	for i in range(stance_buttons.size()):
		var btn = stance_buttons[i]
		var is_active = (i == active)
		btn.add_theme_stylebox_override("normal", _stance_active_style if is_active else _stance_inactive_style)
		btn.modulate = Color(1, 1, 1, 1) if is_active else Color(0.6, 0.6, 0.6, 0.8)

func _on_gold_changed(team: int, amount: int) -> void:
	if team == Global.PLAYER_TEAM:
		gold_label.text = "$" + str(amount)

func _on_population_changed(team: int, current: int, max_pop: int) -> void:
	if team == Global.PLAYER_TEAM:
		pop_label.text = str(current) + "/" + str(max_pop)

func _on_rage_changed(team: int, current: float, max_rage: float) -> void:
	if team != Global.PLAYER_TEAM:
		return
	var pct = current / max_rage
	rage_bar_fill.scale.x = pct
	if pct >= 1.0 and not Global.is_rage_active(Global.PLAYER_TEAM):
		rage_bar_fill.color = Color(1, 0.65, 0.0)
		rage_button.disabled = false
	else:
		rage_bar_fill.color = Color(0.25, 0.45, 0.8)

func _on_rage_pressed() -> void:
	if Global.is_game_over:
		return
	if Global.is_rage_active(Global.PLAYER_TEAM):
		return
	if Global.player_rage < Global.RAGE_MAX:
		return
	Global.activate_rage(Global.PLAYER_TEAM)
	rage_button.disabled = true

func _on_rage_activated(team: int, _duration: float) -> void:
	if team == Global.PLAYER_TEAM:
		rage_bar_fill.color = Color(1, 0.2, 0.1)

func _on_rage_deactivated(team: int) -> void:
	if team == Global.PLAYER_TEAM:
		rage_bar_fill.scale.x = 0.0
		rage_bar_fill.color = Color(0.25, 0.25, 0.35)
		rage_button.disabled = true

func _on_game_over(winner: int) -> void:
	game_over_overlay.show()
	if winner == Global.PLAYER_TEAM:
		winner_label.text = "VICTORY!"
		winner_label.modulate = Color(0.3, 1.0, 0.3)
		# Award currency and mark mission completed
		var mission = Global.get_mission()
		if mission:
			var reward = mission.reward_currency if "reward_currency" in mission else 50
			SaveManager.currency += reward
			var id = SceneManager.pending_mission_id
			if id > 0:
				SaveManager.complete_mission(id)
	else:
		winner_label.text = "DEFEAT"
		winner_label.modulate = Color(1.0, 0.3, 0.3)
	get_tree().paused = true

func _on_game_restarted() -> void:
	game_over_overlay.hide()
	get_tree().paused = false
	_highlight_stance(Global.ArmyStance.ADVANCE)
	rage_bar_fill.scale.x = 0.0
	rage_bar_fill.color = Color(0.25, 0.25, 0.35)
	rage_button.disabled = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.reset_match()
	SignalBus.game_restarted.emit()
	get_tree().reload_current_scene()

func _on_level_select_pressed() -> void:
	get_tree().paused = false
	SceneManager.go_to_level_select()

func _on_shop_pressed() -> void:
	get_tree().paused = false
	SceneManager.go_to_upgrade_shop()
