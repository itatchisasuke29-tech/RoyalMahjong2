extends Control

# ---------------------------------------------------------------------------
# BossBar — HP bar at the top of the screen
# Listens to GameManager.boss_damaged signal
# UI built entirely in code (no .tscn children)
# ---------------------------------------------------------------------------

const BAR_H:        float = 90.0
const PADDING:      float = 10.0
const HP_BAR_H:     float = 22.0

const COLOR_BG:       Color = Color(0.08, 0.05, 0.02, 0.95)
const COLOR_HP_FILL:  Color = Color(0.85, 0.15, 0.10)
const COLOR_HP_EMPTY: Color = Color(0.30, 0.08, 0.06)
const COLOR_DEFEATED: Color = Color(0.20, 0.70, 0.20)

var _hp_fill:    ColorRect
var _hp_label:   Label
var _name_label: Label
var _bar_width:  float = 0.0

func _ready() -> void:
	var vp_w: float = get_viewport_rect().size.x
	set_position(Vector2(0.0, 0.0))
	set_size(Vector2(vp_w, BAR_H))
	_bar_width = vp_w - PADDING * 2.0

	# Dark background
	var bg := ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Boss name label
	_name_label = Label.new()
	_name_label.position = Vector2(PADDING, 6.0)
	_name_label.size     = Vector2(_bar_width, 28.0)
	_name_label.add_theme_font_size_override("font_size", 20)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_label)

	# HP bar background (empty/dark red)
	var hp_bg := ColorRect.new()
	hp_bg.color    = COLOR_HP_EMPTY
	hp_bg.position = Vector2(PADDING, 40.0)
	hp_bg.size     = Vector2(_bar_width, HP_BAR_H)
	add_child(hp_bg)

	# HP bar fill (bright red, shrinks on damage)
	_hp_fill = ColorRect.new()
	_hp_fill.color    = COLOR_HP_FILL
	_hp_fill.position = Vector2(PADDING, 40.0)
	_hp_fill.size     = Vector2(_bar_width, HP_BAR_H)
	add_child(_hp_fill)

	# HP fraction label overlaid on bar
	_hp_label = Label.new()
	_hp_label.position = Vector2(PADDING, 40.0)
	_hp_label.size     = Vector2(_bar_width, HP_BAR_H)
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_hp_label.add_theme_font_size_override("font_size", 14)
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hp_label)

	# Connect AFTER layout is built
	GameManager.boss_damaged.connect(_on_boss_damaged)
	GameManager.boss_set.connect(_on_boss_set)

# ---------------------------------------------------------------------------
func _refresh(hp: int, max_hp: int) -> void:
	_name_label.text = GameManager.boss_name

	if max_hp <= 0:
		return

	var pct: float = float(hp) / float(max_hp)
	_hp_fill.size.x = _bar_width * pct
	_hp_label.text  = "%d / %d HP" % [hp, max_hp]

	if hp == 0:
		_hp_fill.color   = COLOR_DEFEATED
		_hp_label.text   = "Boss Defeated!"
		_name_label.text = GameManager.boss_name + " — Defeated!"

func _on_boss_set(_name: String, hp: int, max_hp: int) -> void:
	# Reset fill color (clears the green "Defeated" state from the previous boss)
	_hp_fill.color = COLOR_HP_FILL
	_refresh(hp, max_hp)

func _on_boss_damaged(new_hp: int, max_hp: int) -> void:
	_animate_damage(new_hp, max_hp)

func _animate_damage(new_hp: int, max_hp: int) -> void:
	var target_w: float = _bar_width * (float(new_hp) / float(max_hp))

	var tween := create_tween()
	# Flash white then back to red
	tween.tween_property(_hp_fill, "color", Color.WHITE, 0.06)
	tween.tween_property(_hp_fill, "color", COLOR_HP_FILL if new_hp > 0 else COLOR_DEFEATED, 0.14)

	# Shrink HP bar width
	var tween2 := create_tween()
	tween2.tween_property(_hp_fill, "size:x", target_w, 0.25).set_ease(Tween.EASE_OUT)

	# Shake the whole bar
	var ox: float = position.x
	var tween3 := create_tween()
	tween3.tween_property(self, "position:x", ox - 6.0, 0.05)
	tween3.tween_property(self, "position:x", ox + 6.0, 0.05)
	tween3.tween_property(self, "position:x", ox - 3.0, 0.04)
	tween3.tween_property(self, "position:x", ox,       0.04)

	# Update text after bar settles
	await tween2.finished
	_hp_label.text = "%d / %d HP" % [new_hp, max_hp]
	if new_hp == 0:
		_hp_label.text   = "Boss Defeated!"
		_name_label.text = GameManager.boss_name + " — Defeated!"
