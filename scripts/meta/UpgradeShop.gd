extends Control

var _unit_types: Array = ["swordsman", "archer", "heavy", "fast", "miner"]
var _display_names: Dictionary = {
	"swordsman": "Swordsman", "archer": "Archer",
	"heavy": "Heavy", "fast": "Fast", "miner": "Miner",
}

func _ready() -> void:
	$BackButton.pressed.connect(_on_back)
	_populate_shop()

func _populate_shop() -> void:
	var container = $ScrollContainer/VBoxContainer
	for child in container.get_children():
		child.queue_free()
	await get_tree().process_frame

	# Currency display
	var currency_label = Label.new()
	currency_label.text = "Currency: $" + str(SaveManager.currency)
	currency_label.theme_override_font_sizes["font_size"] = 20
	currency_label.theme_override_colors["font_color"] = Color(1, 0.85, 0.2)
	container.add_child(currency_label)
	container.add_child(HSeparator.new())

	for t in _unit_types:
		var unit_header = Label.new()
		unit_header.text = _display_names[t]
		unit_header.theme_override_font_sizes["font_size"] = 18
		unit_header.theme_override_colors["font_color"] = Color(0.6, 0.7, 0.9)
		container.add_child(unit_header)

		var stats_to_show = SaveManager.UPGRADE_STATS[t]
		var hbox = HBoxContainer.new()
		for s in stats_to_show:
			var current_level = SaveManager.get_upgrade_level(t, s)
			var cost = SaveManager.get_upgrade_cost(t, s)
			var mult = SaveManager.get_upgrade_mult_for(t, s)

			var stat_box = VBoxContainer.new()
			stat_box.custom_minimum_size = Vector2(180, 60)

			var name_label = Label.new()
			name_label.text = s.capitalize()
			name_label.theme_override_font_sizes["font_size"] = 12
			stat_box.add_child(name_label)

			var value_label = Label.new()
			value_label.theme_override_font_sizes["font_size"] = 11
			if s == "gold_cost":
				value_label.text = "Cost: " + str(int(round(mult * 100))) + "%"
			else:
				value_label.text = "+" + str(int(round((mult - 1.0) * 100))) + "%"
			stat_box.add_child(value_label)

			var level_label = Label.new()
			level_label.text = "Lv." + str(current_level) + "/" + str(SaveManager.MAX_LEVEL)
			level_label.theme_override_font_sizes["font_size"] = 10
			level_label.theme_override_colors["font_color"] = Color(0.5, 0.5, 0.7)
			stat_box.add_child(level_label)

			var buy_btn = Button.new()
			if cost < 0:
				buy_btn.text = "MAX"
				buy_btn.disabled = true
			elif SaveManager.currency >= cost:
				buy_btn.text = "$" + str(cost)
				var type_copy = t
				var stat_copy = s
				buy_btn.pressed.connect(func():
					if SaveManager.purchase_upgrade(type_copy, stat_copy):
						_populate_shop()
				)
			else:
				buy_btn.text = "$" + str(cost)
				buy_btn.disabled = true
			buy_btn.custom_minimum_size = Vector2(80, 30)
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.12, 0.14, 0.22)
			style.border_color = Color(0.2, 0.25, 0.35)
			style.corner_radius_top_left = 6
			style.corner_radius_top_right = 6
			style.corner_radius_bottom_right = 6
			style.corner_radius_bottom_left = 6
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			buy_btn.add_theme_stylebox_override("normal", style)
			buy_btn.theme_override_font_sizes["font_size"] = 11
			stat_box.add_child(buy_btn)

			hbox.add_child(stat_box)
		container.add_child(hbox)
		container.add_child(HSeparator.new())

func _process(_delta: float) -> void:
	# Refresh currency display
	var container = $ScrollContainer/VBoxContainer
	if container.get_child_count() > 0 and container.get_child(0) is Label:
		container.get_child(0).text = "Currency: $" + str(SaveManager.currency)

func _on_back() -> void:
	SceneManager.go_to_main_menu()
