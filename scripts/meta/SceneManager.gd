extends Node

var pending_mission_id: int = -1

func go_to_main_menu() -> void:
	pending_mission_id = -1
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func go_to_level_select() -> void:
	pending_mission_id = -1
	get_tree().change_scene_to_file("res://scenes/menus/LevelSelect.tscn")

func go_to_upgrade_shop() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/UpgradeShop.tscn")

func start_mission(mission_id: int) -> void:
	pending_mission_id = mission_id
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func retry_mission() -> void:
	get_tree().reload_current_scene()
