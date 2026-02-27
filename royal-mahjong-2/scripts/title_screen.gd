extends Node2D

# ---------------------------------------------------------------------------
# TitleScreen — Entry point. All UI built in code.
# ---------------------------------------------------------------------------

const MAIN_SCENE := "res://scenes/Main.tscn"

const COLOR_BG:       Color = Color(0.06, 0.04, 0.01)
const COLOR_GOLD:     Color = Color(0.95, 0.80, 0.25)
const COLOR_CREAM:    Color = Color(0.90, 0.85, 0.70)
const COLOR_DIM:      Color = Color(0.60, 0.55, 0.42)
const COLOR_BTN:      Color = Color(0.55, 0.35, 0.08)
const COLOR_BTN_HOV:  Color = Color(0.75, 0.50, 0.12)

func _ready() -> void:
	var vp: Vector2 = get_viewport_rect().size
	_build_ui(vp)

func _build_ui(vp: Vector2) -> void:
	# Full-screen background
	var bg := ColorRect.new()
	bg.color = COLOR_BG
	bg.position = Vector2.ZERO
	bg.size = vp
	add_child(bg)

	# Decorative top bar
	var top_bar := ColorRect.new()
	top_bar.color    = Color(0.55, 0.35, 0.08, 0.6)
	top_bar.position = Vector2(0.0, 0.0)
	top_bar.size     = Vector2(vp.x, 6.0)
	add_child(top_bar)

	# Title
	var title := Label.new()
	title.text = "ROYAL\nMAHJONG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.position = Vector2(0.0, vp.y * 0.10)
	title.size     = Vector2(vp.x, 200.0)
	title.add_theme_font_size_override("font_size", 58)
	title.add_theme_color_override("font_color", COLOR_GOLD)
	add_child(title)

	# Tagline
	var tagline := Label.new()
	tagline.text = "Save the Emperor from the forces of chaos."
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.position = Vector2(20.0, vp.y * 0.10 + 220.0)
	tagline.size     = Vector2(vp.x - 40.0, 40.0)
	tagline.add_theme_font_size_override("font_size", 16)
	tagline.add_theme_color_override("font_color", COLOR_CREAM)
	add_child(tagline)

	# Divider
	var divider := ColorRect.new()
	divider.color    = COLOR_GOLD
	divider.position = Vector2(vp.x * 0.25, vp.y * 0.10 + 270.0)
	divider.size     = Vector2(vp.x * 0.5, 2.0)
	add_child(divider)

	# Save info
	var save_exists: bool = SaveManager.has_save()
	var info_text: String = ""
	if save_exists and GameManager.current_level > 1:
		info_text = "Level %d  •  Score: %d" % [GameManager.current_level, GameManager.score]
	else:
		info_text = "Match tiles. Defeat bosses. Restore the throne."

	var info := Label.new()
	info.text = info_text
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.position = Vector2(20.0, vp.y * 0.10 + 290.0)
	info.size     = Vector2(vp.x - 40.0, 36.0)
	info.add_theme_font_size_override("font_size", 15)
	info.add_theme_color_override("font_color", COLOR_DIM)
	add_child(info)

	# Play / Continue button
	var btn_y: float = vp.y * 0.60
	var btn_label: String = "CONTINUE" if (save_exists and GameManager.current_level > 1) else "PLAY"

	_make_button(btn_label, Vector2(vp.x * 0.5 - 120.0, btn_y), Vector2(240.0, 70.0), _on_play_pressed)

	# New Game button (only shown when save exists)
	if save_exists and GameManager.current_level > 1:
		var ng_lbl := Label.new()
		ng_lbl.text = "New Game"
		ng_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ng_lbl.position = Vector2(0.0, btn_y + 90.0)
		ng_lbl.size     = Vector2(vp.x, 30.0)
		ng_lbl.add_theme_font_size_override("font_size", 15)
		ng_lbl.add_theme_color_override("font_color", COLOR_DIM)
		ng_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(ng_lbl)
		ng_lbl.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				_on_new_game_pressed()
		)

	# Bottom flavour text
	var flavour := Label.new()
	flavour.text = "5 Levels  •  10 Tile Types  •  Calming Gameplay"
	flavour.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavour.position = Vector2(20.0, vp.y - 80.0)
	flavour.size     = Vector2(vp.x - 40.0, 30.0)
	flavour.add_theme_font_size_override("font_size", 13)
	flavour.add_theme_color_override("font_color", COLOR_DIM)
	add_child(flavour)

func _make_button(label_text: String, pos: Vector2, sz: Vector2, callback: Callable) -> void:
	var btn_bg := ColorRect.new()
	btn_bg.color    = COLOR_BTN
	btn_bg.position = pos
	btn_bg.size     = sz
	btn_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(btn_bg)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", COLOR_GOLD)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_bg.add_child(lbl)

	btn_bg.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			callback.call()
	)
	btn_bg.mouse_entered.connect(func(): btn_bg.color = COLOR_BTN_HOV)
	btn_bg.mouse_exited.connect(func():  btn_bg.color = COLOR_BTN)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_new_game_pressed() -> void:
	SaveManager.reset_save()
	get_tree().change_scene_to_file(MAIN_SCENE)
