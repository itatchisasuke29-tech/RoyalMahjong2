extends Control

# ---------------------------------------------------------------------------
# SlotBar — 4-slot bar + Match-2 logic
# game_board is injected by Main._ready() — do NOT look it up here
# ---------------------------------------------------------------------------

var game_board: Node = null

# IDs of tiles currently held in the bar (max 4)
var slot_ids: Array[int] = []

const COLOR_EMPTY:    Color = Color(0.30, 0.25, 0.18)
const COLOR_OCCUPIED: Color = Color(0.94, 0.85, 0.65)
const COLOR_MATCH:    Color = Color(0.40, 0.85, 0.40)

@onready var slot_bgs: Array[ColorRect] = [
	$HBoxContainer/Slot0/BG,
	$HBoxContainer/Slot1/BG,
	$HBoxContainer/Slot2/BG,
	$HBoxContainer/Slot3/BG,
]
@onready var slot_labels: Array[Label] = [
	$HBoxContainer/Slot0/Label,
	$HBoxContainer/Slot1/Label,
	$HBoxContainer/Slot2/Label,
	$HBoxContainer/Slot3/Label,
]

# ---------------------------------------------------------------------------
func _ready() -> void:
	GameManager.tile_clicked.connect(_on_tile_clicked)
	_update_visuals()

# ---------------------------------------------------------------------------
# Tile tapped on board
# ---------------------------------------------------------------------------
func _on_tile_clicked(tile: Node) -> void:
	if slot_ids.size() >= 4:
		return

	var id: int = tile.tile_id

	# Remove from board grid and free the node immediately
	if game_board:
		game_board.take_tile(tile)
		game_board.discard_tile(tile)
	else:
		push_error("SlotBar: game_board not set — tile click ignored")
		return

	slot_ids.append(id)
	_update_visuals()
	_check_for_matches()

# ---------------------------------------------------------------------------
# Match-2 logic
# ---------------------------------------------------------------------------
func _check_for_matches() -> void:
	for i in range(slot_ids.size()):
		for j in range(i + 1, slot_ids.size()):
			if slot_ids[i] == slot_ids[j]:
				_handle_match(i, j)
				return

	if slot_ids.size() >= 4:
		GameManager.game_over.emit()
		print("GAME OVER: bar full with no valid match!")

func _handle_match(i: int, j: int) -> void:
	var matched_id: int = slot_ids[i]
	# Remove higher index first to avoid shifting the lower one
	slot_ids.remove_at(j)
	slot_ids.remove_at(i)

	GameManager.match_made.emit(null, null)
	GameManager.add_score(10)
	GameManager.damage_boss(1)

	_update_visuals()
	print("Match! id:%d  score:%d  boss_hp:%d" % [matched_id, GameManager.score, GameManager.boss_hp])

# ---------------------------------------------------------------------------
# Visuals
# ---------------------------------------------------------------------------
func _update_visuals() -> void:
	for i in range(4):
		if i < slot_ids.size():
			slot_bgs[i].color   = COLOR_OCCUPIED
			slot_labels[i].text = str(slot_ids[i])
		else:
			slot_bgs[i].color   = COLOR_EMPTY
			slot_labels[i].text = ""
