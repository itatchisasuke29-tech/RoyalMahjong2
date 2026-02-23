extends Node

# ---------------------------------------------------------------------------
# GameManager — Global Autoload (Signal Bus + Game State)
# Registered in project.godot as "GameManager"
# Access anywhere with: GameManager.signal_name / GameManager.variable
# ---------------------------------------------------------------------------

# --- Signals ---
signal tile_clicked(tile: Node)       # emitted by Tile when tapped
signal match_made(tile1: Node, tile2: Node)  # emitted by SlotBar on a successful pair
signal game_over()                    # emitted by SlotBar when bar is full, no match
signal board_cleared()                # emitted by GameBoard when all tiles removed

# --- Game State ---
var current_level: int = 1
var score: int = 0
var boss_hp: int = 0
var boss_hp_max: int = 0

# --- Called automatically by Godot (Autoload is always ready) ---
func _ready() -> void:
	print("GameManager ready.")

# ---------------------------------------------------------------------------
# Helpers called by other nodes
# ---------------------------------------------------------------------------

func add_score(points: int) -> void:
	score += points

func set_boss_hp(hp: int) -> void:
	boss_hp = hp
	boss_hp_max = hp

func damage_boss(amount: int) -> void:
	boss_hp = max(0, boss_hp - amount)
	if boss_hp == 0:
		emit_signal("board_cleared")  # re-use cleared signal for boss defeat for now

func reset_for_level(level_id: int) -> void:
	current_level = level_id
	score = 0
