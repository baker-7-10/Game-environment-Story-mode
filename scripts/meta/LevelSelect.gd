extends Control

const MISSION_COUNT: int = 10
const MISSION_SCRIPT = preload("res://scripts/meta/MissionResource.gd")
var _mission_resources: Dictionary = {}

func _ready() -> void:
	_preload_missions()
	_populate_grid()
	$BackButton.pressed.connect(_on_back)

func _preload_missions() -> void:
	for i in range(1, MISSION_COUNT + 1):
		var path = "res://resources/Missions/Mission" + str(i) + ".tres"
		var res = load(path)
		if res:
			_mission_resources[i] = res
		else:
			var placeholder = MISSION_SCRIPT.new()
			placeholder.mission_id = i
			placeholder.mission_name = "Level " + str(i)
			_mission_resources[i] = placeholder

func _populate_grid() -> void:
	var grid = $ScrollContainer/GridContainer
	for child in grid.get_children():
		child.queue_free()
	await get_tree().process_frame

	for i in range(1, MISSION_COUNT + 1):
		var res = _mission_resources.get(i)
		if not res:
			continue
		var unlocked = SaveManager.is_mission_unlocked(i)
		var completed = SaveManager.is_mission_completed(i)

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(300, 120)
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_right = 10
		style.corner_radius_bottom_left = 10
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		if completed:
			style.bg_color = Color(0.12, 0.25, 0.12)
			style.border_color = Color(0.2, 0.5, 0.2)
		elif unlocked:
			style.bg_color = Color(0.12, 0.14, 0.22)
			style.border_color = Color(0.2, 0.25, 0.35)
		else:
			style.bg_color = Color(0.06, 0.06, 0.1)
			style.border_color = Color(0.1, 0.1, 0.15)

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_font_size_override("font_size", 14)

		var label_text = "Level " + str(i)
		if unlocked and res.description:
			label_text += "\n" + res.description
		if completed:
			label_text += "\n[COMPLETED]"
		btn.text = label_text

		if unlocked:
			var id = i
			btn.pressed.connect(func(): _start_mission(id))
		else:
			btn.disabled = true

		grid.add_child(btn)

func _start_mission(id: int) -> void:
	SceneManager.start_mission(id)

func _on_back() -> void:
	SceneManager.go_to_main_menu()
