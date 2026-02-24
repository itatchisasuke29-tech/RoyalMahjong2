extends Area2D

# ---------------------------------------------------------------------------
# Tile — One mahjong tile on the board
# Attached to: scenes/Tile.tscn (Area2D root)
# ---------------------------------------------------------------------------

var tile_id:   int    = 0
var tile_name: String = ""
var tile_color: Color = Color(0.94, 0.85, 0.65)
var grid_x: int = 0
var grid_y: int = 0
var grid_z: int = 0
var is_free: bool = true

const TILE_W: float = 120.0
const TILE_H: float = 150.0

# One color per tile ID (index 0 = fallback)
const TILE_COLORS: Array[Color] = [
	Color(0.94, 0.85, 0.65),  # 0: fallback beige
	Color(0.22, 0.68, 0.32),  # 1: Bamboo    — green
	Color(0.88, 0.72, 0.12),  # 2: Coin       — gold
	Color(0.82, 0.18, 0.18),  # 3: Dragon     — crimson
	Color(0.28, 0.58, 0.88),  # 4: Wind       — sky blue
	Color(0.90, 0.42, 0.62),  # 5: Flower     — rose
	Color(0.92, 0.52, 0.12),  # 6: Season     — orange
	Color(0.52, 0.22, 0.80),  # 7: Gem        — purple
	Color(0.88, 0.32, 0.15),  # 8: Phoenix    — deep orange
	Color(0.85, 0.60, 0.10),  # 9: Tiger      — amber
	Color(0.38, 0.72, 0.88),  # 10: Cloud     — cyan
]

@onready var bg:    ColorRect = $ColorRect
@onready var label: Label     = $Label

# ---------------------------------------------------------------------------
# Called by GameBoard after instancing the scene
# ---------------------------------------------------------------------------
func setup(id: int, name: String, gx: int, gy: int, gz: int) -> void:
	tile_id    = id
	tile_name  = name
	tile_color = TILE_COLORS[id] if id < TILE_COLORS.size() else TILE_COLORS[0]
	grid_x     = gx
	grid_y     = gy
	grid_z     = gz
	label.text = name
	z_index    = gz
	_refresh_visuals()

# ---------------------------------------------------------------------------
# Called by GameBoard whenever tiles are removed (re-evaluate neighbours)
# ---------------------------------------------------------------------------
func set_free(value: bool) -> void:
	is_free        = value
	input_pickable = value
	_refresh_visuals()

# ---------------------------------------------------------------------------
# Visuals
# ---------------------------------------------------------------------------
func _refresh_visuals() -> void:
	if is_free:
		bg.color = tile_color
		modulate  = Color.WHITE
	else:
		bg.color = tile_color * 0.5
		modulate  = Color(0.8, 0.8, 0.8)

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_free:
			GameManager.tile_clicked.emit(self)

func _on_mouse_entered() -> void:
	if is_free:
		bg.color = tile_color.lightened(0.25)

func _on_mouse_exited() -> void:
	if is_free:
		bg.color = tile_color
