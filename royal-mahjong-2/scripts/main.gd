extends Node2D

const LEVELS: Array[String] = [
	"res://data/levels/level_01.json",
	"res://data/levels/level_02.json",
]

@onready var game_board:        Node   = $GameBoard
@onready var slot_bar:          Node   = $UILayer/UIRoot/SlotBar
@onready var score_label:       Label  = $UILayer/UIRoot/HUD/ScoreLabel
@onready var status_label:      Label  = $UILayer/UIRoot/HUD/StatusLabel
@onready var next_level_button: Button = $UILayer/UIRoot/HUD/NextLevelButton
@onready var restart_button:    Button = $UILayer/UIRoot/HUD/RestartButton
@onready var undo_button:       Button = $UILayer/UIRoot/HUD/UndoButton
@onready var shuffle_button:    Button = $UILayer/UIRoot/HUD/ShuffleButton

var _level_complete: bool = false

func _ready() -> void:
	slot_bar.game_board = game_board

	GameManager.match_made.connect(_on_match_made)
	GameManager.game_over.connect(_on_game_over)
	GameManager.board_cleared.connect(_on_board_cleared)

	next_level_button.pressed.connect(_on_next_level_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	undo_button.pressed.connect(_on_undo_pressed)
	shuffle_button.pressed.connect(_on_shuffle_pressed)

	_load_current_level()

func _load_current_level() -> void:
	var idx: int = GameManager.current_level - 1
	if idx < 0 or idx >= LEVELS.size():
		idx = 0
	_level_complete = false
	next_level_button.visible = false
	restart_button.visible = false
	status_label.text = ""
	slot_bar.reset()
	game_board.load_level(LEVELS[idx])
	_refresh_hud()

func _on_match_made(_t1, _t2) -> void:
	_refresh_hud()
	if not _level_complete:
		status_label.text = "Great match!"

func _on_game_over() -> void:
	status_label.text = "Game Over!"
	restart_button.visible = true

func _on_board_cleared() -> void:
	_level_complete = true
	var next_idx: int = GameManager.current_level
	if next_idx < LEVELS.size():
		status_label.text = "Level complete!"
		next_level_button.visible = true
	else:
		status_label.text = "The Emperor is saved!  You win!"
		restart_button.visible = true

func _on_next_level_pressed() -> void:
	GameManager.current_level += 1
	SaveManager.save_game()
	_load_current_level()

func _on_restart_pressed() -> void:
	SaveManager.reset_save()
	_load_current_level()

func _on_undo_pressed() -> void:
	if GameManager.powerups.get("undo", 0) <= 0:
		return
	if slot_bar.undo_last():
		GameManager.powerups["undo"] -= 1
		SaveManager.save_game()
		_refresh_hud()

func _on_shuffle_pressed() -> void:
	if GameManager.powerups.get("shuffle", 0) <= 0:
		return
	game_board.shuffle_tiles()
	GameManager.powerups["shuffle"] -= 1
	SaveManager.save_game()
	_refresh_hud()

func _refresh_hud() -> void:
	score_label.text = "Score: %d" % GameManager.score
	var undo_count:    int = GameManager.powerups.get("undo", 0)
	var shuffle_count: int = GameManager.powerups.get("shuffle", 0)
	undo_button.text        = "Undo (%d)" % undo_count
	undo_button.disabled    = undo_count <= 0
	shuffle_button.text     = "Shuffle (%d)" % shuffle_count
	shuffle_button.disabled = shuffle_count <= 0
