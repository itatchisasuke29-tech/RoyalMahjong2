extends Node

# ---------------------------------------------------------------------------
# SaveManager — JSON State Machine for meta-game persistence
# Registered as Autoload in project.godot (loads after GameManager)
# Save file: user://save.json  (per-device, safe location on all platforms)
# ---------------------------------------------------------------------------

const SAVE_PATH := "user://save.json"

func _ready() -> void:
	# Load saved state into GameManager on startup
	load_game()
	# Auto-save after every match and level clear
	GameManager.match_made.connect(_on_match_made)
	GameManager.board_cleared.connect(_on_board_cleared)

# ---------------------------------------------------------------------------
# Auto-save triggers
# ---------------------------------------------------------------------------
func _on_match_made(_t1, _t2) -> void:
	save_game()

func _on_board_cleared() -> void:
	save_game()

# ---------------------------------------------------------------------------
# Save
# ---------------------------------------------------------------------------
func save_game() -> void:
	var data := {
		"current_level":  GameManager.current_level,
		"score":          GameManager.score,
		"powerups":       GameManager.powerups.duplicate(),
		"tutorial_seen":  GameManager.tutorial_seen
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: cannot write to " + SAVE_PATH)
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()

# ---------------------------------------------------------------------------
# Load
# ---------------------------------------------------------------------------
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("SaveManager: cannot read " + SAVE_PATH)
		return

	var json := JSON.new()
	var err  := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("SaveManager: corrupt save — resetting.")
		reset_save()
		return

	var data: Dictionary = json.data
	GameManager.current_level          = data.get("current_level", 1)
	GameManager.score                  = data.get("score", 0)

	var saved_pu: Dictionary           = data.get("powerups", {})
	GameManager.powerups["undo"]       = saved_pu.get("undo",    3)
	GameManager.powerups["shuffle"]    = saved_pu.get("shuffle", 1)
	GameManager.tutorial_seen         = data.get("tutorial_seen", false)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# ---------------------------------------------------------------------------
# Reset (call on new game / game over)
# ---------------------------------------------------------------------------
func reset_save() -> void:
	GameManager.current_level  = 1
	GameManager.score          = 0
	GameManager.powerups       = {"undo": 3, "shuffle": 1}
	save_game()
