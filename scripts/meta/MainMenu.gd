extends Control

func _ready() -> void:
	$VBoxContainer/PlayButton.pressed.connect(_on_play)
	$VBoxContainer/ShopButton.pressed.connect(_on_shop)
	$VBoxContainer/ResetButton.pressed.connect(_on_reset)

func _on_play() -> void:
	SceneManager.go_to_level_select()

func _on_shop() -> void:
	SceneManager.go_to_upgrade_shop()

func _on_reset() -> void:
	SaveManager.reset_save()
	$VBoxContainer/ResetButton.text = "RESET DONE"
	await get_tree().create_timer(0.8).timeout
	$VBoxContainer/ResetButton.text = "RESET SAVE"
