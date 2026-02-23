extends Area2D

# ---------------------------------------------------------------------------
# Tile — One mahjong tile on the board
# Attached to: scenes/Tile.tscn (Area2D root)
# ---------------------------------------------------------------------------

# Set by GameBoard when spawning from JSON
var tile_id: int = 0
var grid_x: int = 0
var grid_y: int = 0
var grid_z: int = 0
var is_free: bool = true

# Visual constants — tweak these to resize all tiles at once
const TILE_W: float = 120.0
const TILE_H: float = 150.0

# Colors (placeholder art — swap for sprites later)
const COLOR_FREE:    Color = Color(0.94, 0.85, 0.65)  # warm beige
const COLOR_BLOCKED: Color = Color(0.55, 0.48, 0.38)  # dark when blocked
const COLOR_HOVER:   Color = Color(1.00, 0.96, 0.78)  # bright on hover

@onready var bg:    ColorRect = $ColorRect
@onready var label: Label     = $Label

# ---------------------------------------------------------------------------
# Called by GameBoard after instancing the scene
# ---------------------------------------------------------------------------
func setup(id: int, gx: int, gy: int, gz: int) -> void:
	tile_id = id
	grid_x  = gx
	grid_y  = gy
	grid_z  = gz
	label.text = str(id)   # TODO: replace with tile type name / icon
	z_index = gz           # higher layer renders on top
	_refresh_visuals()

# ---------------------------------------------------------------------------
# Called by GameBoard whenever tiles are removed (re-evaluate neighbours)
# ---------------------------------------------------------------------------
func set_free(value: bool) -> void:
	is_free = value
	input_pickable = value   # Area2D ignores mouse when blocked
	_refresh_visuals()

# ---------------------------------------------------------------------------
# Visuals
# ---------------------------------------------------------------------------
func _refresh_visuals() -> void:
	if is_free:
		bg.color = COLOR_FREE
		modulate  = Color.WHITE
	else:
		bg.color = COLOR_BLOCKED
		modulate  = Color(0.75, 0.75, 0.75)

# ---------------------------------------------------------------------------
# Input (connected in Tile.tscn)
# ---------------------------------------------------------------------------
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_free:
			GameManager.tile_clicked.emit(self)
			print("Tile clicked → id:%d  pos:(%d,%d,%d)" % [tile_id, grid_x, grid_y, grid_z])

func _on_mouse_entered() -> void:
	if is_free:
		bg.color = COLOR_HOVER

func _on_mouse_exited() -> void:
	if is_free:
		bg.color = COLOR_FREE
