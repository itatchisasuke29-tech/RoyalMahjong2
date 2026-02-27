extends Node2D

const LEVELS: Array[String] = [
	"res://data/levels/level_01.json",
	"res://data/levels/level_02.json",
	"res://data/levels/level_03.json",
	"res://data/levels/level_04.json",
	"res://data/levels/level_05.json",
]

@onready var game_board:        Node   = $GameBoard
@onready var slot_bar:          Node   = $UILayer/UIRoot/SlotBar
@onready var ui_root:           Control = $UILayer/UIRoot
@onready var score_label:       Label  = $UILayer/UIRoot/HUD/ScoreLabel
@onready var level_label:       Label  = $UILayer/UIRoot/HUD/LevelLabel
@onready var status_label:      Label  = $UILayer/UIRoot/HUD/StatusLabel
@onready var next_level_button: Button = $UILayer/UIRoot/HUD/NextLevelButton
@onready var restart_button:    Button = $UILayer/UIRoot/HUD/RestartButton
@onready var undo_button:       Button = $UILayer/UIRoot/HUD/UndoButton
@onready var shuffle_button:    Button = $UILayer/UIRoot/HUD/ShuffleButton

var _level_complete: bool = false
var _narrative:      Dictionary = {}

func _ready() -> void:
	slot_bar.game_board = game_board

	GameManager.match_made.connect(_on_match_made)
	GameManager.game_over.connect(_on_game_over)
	GameManager.board_cleared.connect(_on_board_cleared)
	GameManager.boss_damaged.connect(_on_boss_damaged)
	AdManager.reward_granted.connect(_on_reward_granted)

	next_level_button.pressed.connect(_on_next_level_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	undo_button.pressed.connect(_on_undo_pressed)
	shuffle_button.pressed.connect(_on_shuffle_pressed)

	_load_narrative()
	_load_current_level()

func _load_narrative() -> void:
	var file := FileAccess.open("res://data/story/narrative.json", FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_narrative = json.data
	file.close()

func _load_current_level() -> void:
	var idx: int = GameManager.current_level - 1
	if idx < 0 or idx >= LEVELS.size():
		idx = 0
	_level_complete = false
	next_level_button.visible = false
	restart_button.visible    = false
	slot_bar.reset()
	game_board.load_level(LEVELS[idx])
	_refresh_hud()
	_announce_boss()
	var level_key: String = str(GameManager.current_level)
	if _narrative.has(level_key):
		_show_dialogue(_narrative[level_key].get("intro", ""), 4.0)
	if GameManager.current_level == 1 and not GameManager.tutorial_seen:
		_run_tutorial()

func _announce_boss() -> void:
	status_label.text = "%s appears!" % GameManager.boss_name
	await get_tree().create_timer(2.0).timeout
	if not _level_complete:
		status_label.text = ""

func _on_match_made(_t1, _t2) -> void:
	_refresh_hud()
	_show_score_popup("+10")
	if not _level_complete:
		status_label.text = "Great match!"

func _on_game_over() -> void:
	status_label.text = "Game Over!"
	restart_button.visible = true

func _on_boss_damaged(new_hp: int, _max_hp: int) -> void:
	if new_hp == 0:
		_show_level_complete()

func _on_board_cleared() -> void:
	# Guarantee boss always dies when board is cleared
	if GameManager.boss_hp > 0:
		GameManager.damage_boss(GameManager.boss_hp)
	_show_level_complete()

func _show_level_complete() -> void:
	if _level_complete:
		return
	_level_complete = true
	var level_key: String = str(GameManager.current_level)
	var next_idx: int = GameManager.current_level
	if next_idx < LEVELS.size():
		status_label.text = "Level complete!"
		next_level_button.visible = true
	else:
		status_label.text = "The Emperor is saved!  You win!"
		restart_button.text    = "Play Again"
		restart_button.visible = true
	if _narrative.has(level_key):
		_show_dialogue(_narrative[level_key].get("victory", ""), 4.0)

func _on_next_level_pressed() -> void:
	GameManager.current_level += 1
	SaveManager.save_game()
	_load_current_level()

func _on_restart_pressed() -> void:
	# If we just finished the last level, start over from level 1
	if _level_complete and GameManager.current_level >= LEVELS.size():
		GameManager.current_level = 1
		SaveManager.save_game()
	restart_button.text = "Restart"
	_load_current_level()

func _on_undo_pressed() -> void:
	if GameManager.powerups.get("undo", 0) <= 0:
		AdManager.show_rewarded_ad("undo")
		return
	if slot_bar.undo_last():
		GameManager.powerups["undo"] -= 1
		SaveManager.save_game()
		_refresh_hud()

func _on_shuffle_pressed() -> void:
	if GameManager.powerups.get("shuffle", 0) <= 0:
		AdManager.show_rewarded_ad("shuffle")
		return
	game_board.shuffle_tiles()
	GameManager.powerups["shuffle"] -= 1
	SaveManager.save_game()
	_refresh_hud()

func _on_reward_granted(reward_type: String) -> void:
	GameManager.powerups[reward_type] = GameManager.powerups.get(reward_type, 0) + 1
	SaveManager.save_game()
	_refresh_hud()
	status_label.text = "Powerup ready!"
	await get_tree().create_timer(1.5).timeout
	if not _level_complete:
		status_label.text = ""

func _refresh_hud() -> void:
	score_label.text = "Score: %d" % GameManager.score
	level_label.text = "Level %d / %d" % [GameManager.current_level, LEVELS.size()]
	var undo_count:    int = GameManager.powerups.get("undo", 0)
	var shuffle_count: int = GameManager.powerups.get("shuffle", 0)
	undo_button.text     = "Undo (%d)" % undo_count if undo_count > 0 else "Undo (Ad)"
	undo_button.disabled = false
	shuffle_button.text     = "Shuffle (%d)" % shuffle_count if shuffle_count > 0 else "Shuffle (Ad)"
	shuffle_button.disabled = false

func _show_dialogue(text: String, duration: float) -> void:
	if text.is_empty():
		return
	var vp: Vector2 = get_viewport_rect().size

	var panel := Panel.new()
	panel.position     = Vector2(16.0, vp.y * 0.42)
	panel.size         = Vector2(vp.x - 32.0, 100.0)
	panel.z_index      = 20
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(panel)

	var lbl := Label.new()
	lbl.text         = "Emperor: " + text
	lbl.position     = Vector2(12.0, 8.0)
	lbl.size         = Vector2(panel.size.x - 24.0, panel.size.y - 16.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.60))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl)

	await get_tree().create_timer(duration).timeout
	var tween := panel.create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	await tween.finished
	panel.queue_free()

func _run_tutorial() -> void:
	var steps: Array = [
		["How to Play",   "Tap any glowing tile to pick it up and add it to your slot bar at the bottom."],
		["Make Matches!", "Match 2 identical tiles to deal damage to the boss and clear the board."],
		["Watch Out!",    "If your slot bar fills with 4 unmatched tiles — it's Game Over!\nPlan your moves carefully."],
	]
	for step: Array in steps:
		await _show_tutorial_step(step[0], step[1])
	GameManager.tutorial_seen = true
	SaveManager.save_game()

func _show_tutorial_step(title: String, body: String) -> void:
	var vp: Vector2 = get_viewport_rect().size

	# Dark overlay — blocks all input underneath
	var overlay := ColorRect.new()
	overlay.color       = Color(0.0, 0.0, 0.0, 0.65)
	overlay.z_index     = 30
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_root.add_child(overlay)

	# Card panel
	var panel := Panel.new()
	panel.position     = Vector2(30.0, vp.y * 0.28)
	panel.size         = Vector2(vp.x - 60.0, 280.0)
	panel.z_index      = 31
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(panel)

	var title_lbl := Label.new()
	title_lbl.text                     = title
	title_lbl.position                 = Vector2(16.0, 16.0)
	title_lbl.size                     = Vector2(panel.size.x - 32.0, 40.0)
	title_lbl.horizontal_alignment     = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 24)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.30))
	title_lbl.mouse_filter             = Control.MOUSE_FILTER_IGNORE
	panel.add_child(title_lbl)

	var body_lbl := Label.new()
	body_lbl.text                  = body
	body_lbl.position              = Vector2(16.0, 68.0)
	body_lbl.size                  = Vector2(panel.size.x - 32.0, 160.0)
	body_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	body_lbl.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	body_lbl.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.add_theme_font_size_override("font_size", 18)
	body_lbl.mouse_filter          = Control.MOUSE_FILTER_IGNORE
	panel.add_child(body_lbl)

	var hint_lbl := Label.new()
	hint_lbl.text               = "Tap anywhere to continue"
	hint_lbl.position           = Vector2(16.0, panel.size.y - 36.0)
	hint_lbl.size               = Vector2(panel.size.x - 32.0, 28.0)
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_size_override("font_size", 14)
	hint_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	hint_lbl.mouse_filter       = Control.MOUSE_FILTER_IGNORE
	panel.add_child(hint_lbl)

	# Invisible full-screen button catches the tap
	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.z_index = 32
	overlay.add_child(btn)

	await btn.pressed

	var tween := overlay.create_tween().set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.25)
	tween.tween_property(panel,   "modulate:a", 0.0, 0.25)
	await tween.finished
	overlay.queue_free()
	panel.queue_free()

func _show_score_popup(text: String) -> void:
	var vp: Vector2 = get_viewport_rect().size
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.20))
	lbl.position = Vector2(vp.x * 0.5 - 30.0, vp.y - 240.0)
	lbl.z_index  = 10
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(lbl)

	var tween := lbl.create_tween().set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - 70.0, 0.75).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.75).set_ease(Tween.EASE_IN)
	await tween.finished
	lbl.queue_free()
