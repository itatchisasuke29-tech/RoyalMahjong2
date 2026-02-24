extends Node

# ---------------------------------------------------------------------------
# GameManager — Global Autoload (Signal Bus + Game State)
# ---------------------------------------------------------------------------

# --- Signals ---
signal tile_clicked(tile: Node)
signal match_made(tile1: Node, tile2: Node)
signal game_over()
signal board_cleared()
signal boss_damaged(new_hp: int, max_hp: int)   # fires AFTER HP is reduced
signal boss_set(boss_name: String, hp: int, max_hp: int)  # fires when a new boss is loaded

# --- Game State ---
var current_level: int = 1
var score:         int = 0
var boss_hp:       int = 0
var boss_hp_max:   int = 0
var boss_name:     String = ""
var powerups:      Dictionary = {"undo": 3, "shuffle": 1}

func _ready() -> void:
	get_viewport().physics_object_picking = true

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func add_score(points: int) -> void:
	score += points

func set_boss(name: String, hp: int) -> void:
	boss_name    = name
	boss_hp      = hp
	boss_hp_max  = hp
	boss_set.emit(boss_name, boss_hp, boss_hp_max)

func damage_boss(amount: int) -> void:
	boss_hp = max(0, boss_hp - amount)
	boss_damaged.emit(boss_hp, boss_hp_max)

func reset_for_level(level_id: int) -> void:
	current_level = level_id
	score = 0
