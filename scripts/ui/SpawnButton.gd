extends Button

@export var unit_type: String = "swordsman"
@export var unit_cost: int = 100

var _effective_cost:
	get:
		return max(1, int(round(unit_cost * SaveManager.get_upgrade_mult_for(unit_type, "gold_cost"))))

func _ready() -> void:
	pressed.connect(_on_pressed)
	icon = _generate_icon(unit_type)

func _process(_delta: float) -> void:
	var at_pop_cap = Global.get_population(Global.PLAYER_TEAM) >= Global.MAX_POPULATION
	var cost = _effective_cost
	disabled = at_pop_cap or Global.get_gold(Global.PLAYER_TEAM) < cost
	text = "$" + str(cost)

func _on_pressed() -> void:
	if Global.get_population(Global.PLAYER_TEAM) >= Global.MAX_POPULATION:
		return
	if unit_type == "miner" and Global.get_miner_count(Global.PLAYER_TEAM) >= Global.MAX_MINERS_PER_TEAM:
		return
	var cost = _effective_cost
	if Global.get_gold(Global.PLAYER_TEAM) >= cost:
		Global.modify_gold(Global.PLAYER_TEAM, -cost)
		SignalBus.unit_spawned.emit(Global.PLAYER_TEAM, null, unit_type)

static func _generate_icon(type: String) -> Texture2D:
	var S = 64
	var img = Image.create(S, S, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	match type:
		"swordsman":
			var blade = Color(0.7, 0.85, 1.0, 0.95)
			var guard = Color(0.6, 0.7, 0.9, 0.95)
			var hilt = Color(0.55, 0.35, 0.1, 0.95)
			img.fill_rect(Rect2i(28, 2, 8, 26), blade)
			img.fill_rect(Rect2i(14, 22, 36, 6), guard)
			img.fill_rect(Rect2i(28, 28, 8, 22), hilt)
			img.fill_rect(Rect2i(25, 48, 14, 8), guard)

		"archer":
			var limb = Color(0.5, 0.8, 0.5, 0.95)
			var grip = Color(0.5, 0.35, 0.1, 0.95)
			var str = Color(0.9, 0.9, 0.7, 0.7)
			# Upper limb
			img.fill_rect(Rect2i(26, 2, 8, 10), limb)
			img.fill_rect(Rect2i(32, 8, 8, 10), limb)
			# Lower limb
			img.fill_rect(Rect2i(32, 36, 8, 10), limb)
			img.fill_rect(Rect2i(26, 44, 8, 10), limb)
			# Grip
			img.fill_rect(Rect2i(20, 18, 18, 20), grip)
			# Bowstring (vertical line)
			img.fill_rect(Rect2i(18, 4, 4, 52), str)

		"heavy":
			var head = Color(0.9, 0.65, 0.4, 0.95)
			var handle = Color(0.45, 0.3, 0.08, 0.95)
			# Axe/club head (large block)
			img.fill_rect(Rect2i(12, 4, 40, 28), head)
			# Handle
			img.fill_rect(Rect2i(28, 28, 8, 26), handle)
			# Wrap
			img.fill_rect(Rect2i(27, 30, 10, 6), Color(0.6, 0.4, 0.15, 0.95))
			# Blade edge
			img.fill_rect(Rect2i(14, 10, 6, 18), Color(0.85, 0.85, 0.9, 0.95))

		"fast":
			var blade = Color(0.6, 0.85, 1.0, 0.95)
			var hilt = Color(0.5, 0.35, 0.1, 0.95)
			# Dagger blade (tapered - drawn as stacked rects)
			for i in range(16):
				var w = 12 - i / 2
				var x = 26 - w / 2
				img.fill_rect(Rect2i(x, 4 + i, w, 2), blade)
			# Crossguard
			img.fill_rect(Rect2i(18, 18, 28, 4), Color(0.7, 0.7, 0.8, 0.95))
			# Handle
			img.fill_rect(Rect2i(28, 22, 8, 22), hilt)
			img.fill_rect(Rect2i(30, 24, 4, 18), Color(0.3, 0.2, 0.05, 0.95))

		"miner":
			var metal = Color(0.7, 0.7, 0.75, 0.95)
			var handle = Color(0.5, 0.3, 0.06, 0.95)
			# Pickaxe head (L-shape)
			img.fill_rect(Rect2i(14, 6, 34, 8), metal)
			img.fill_rect(Rect2i(40, 4, 8, 18), metal)
			img.fill_rect(Rect2i(14, 10, 8, 18), metal)
			# Handle
			img.fill_rect(Rect2i(24, 22, 8, 34), handle)
			# Metal band
			img.fill_rect(Rect2i(23, 20, 10, 4), Color(0.6, 0.5, 0.2, 0.95))

	# Center dot for all icons
	img.set_pixel(32, 32, Color(1, 1, 1, 0.1))

	return ImageTexture.create_from_image(img)
