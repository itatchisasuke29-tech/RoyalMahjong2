extends Node2D

# ---------------------------------------------------------------------------
# Main — Root scene controller
# ---------------------------------------------------------------------------

@onready var game_board:    Node  = $GameBoard
@onready var slot_bar:      Node  = $UILayer/SlotBar
@onready var score_label:  Label  = $UILayer/HUD/ScoreLabel
@onready var status_label: Label  = $UILayer/HUD/StatusLabel

func _ready() -> void:
	# Inject game_board into SlotBar (avoids group-lookup timing issues)
	slot_bar.game_board = game_board

	GameManager.match_made.connect(_on_match_made)
	GameManager.game_over.connect(_on_game_over)
	GameManager.board_cleared.connect(_on_board_cleared)

	game_board.load_level("res://data/levels/level_01.json")
	_refresh_hud()

func _on_match_made(_tile1, _tile2) -> void:
	_refresh_hud()
	status_label.text = "Great match!"

func _on_game_over() -> void:
	status_label.text = "Bar is full — no match! Game Over."

func _on_board_cleared() -> void:
	status_label.text = "Level complete!"

func _refresh_hud() -> void:
	score_label.text = "Score: %d" % GameManager.score
