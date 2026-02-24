extends Control

# ---------------------------------------------------------------------------
# SlotBar — builds its own UI in code so there are no .tscn loading issues
# ---------------------------------------------------------------------------

var game_board: Node = null
var slot_ids: Array[int] = []
var slot_bgs:    Array[ColorRect] = []
var slot_labels: Array[Label]     = []

# The last tile node taken from the board — kept alive for Undo
var _undo_tile: Node = null

const COLOR_EMPTY:    Color = Color(0.28, 0.22, 0.14)
const COLOR_OCCUPIED: Color = Color(0.94, 0.85, 0.65)
const BAR_HEIGHT: float = 200.0
const SLOT_W:     float = 140.0
const SLOT_H:     float = 165.0
const SLOT_GAP:   float = 14.0

func _ready() -> void:
	# --- Size this control to the bottom strip of the viewport ---
	var vp_size: Vector2 = get_viewport_rect().size
	set_position(Vector2(0.0, vp_size.y - BAR_HEIGHT))
	set_size(Vector2(vp_size.x, BAR_HEIGHT))

	# Dark background
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.07, 0.03, 0.95)
	bar_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bar_bg)

	# 4 slot panels, centered horizontally
	var total_w := 4.0 * SLOT_W + 3.0 * SLOT_GAP
	var ox := (vp_size.x - total_w) * 0.5
	var oy := (BAR_HEIGHT - SLOT_H) * 0.5

	for i in range(4):
		var bg := ColorRect.new()
		bg.color    = COLOR_EMPTY
		bg.position = Vector2(ox + i * (SLOT_W + SLOT_GAP), oy)
		bg.size     = Vector2(SLOT_W, SLOT_H)
		add_child(bg)
		slot_bgs.append(bg)

		var lbl := Label.new()
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.add_child(lbl)
		slot_labels.append(lbl)

	GameManager.tile_clicked.connect(_on_tile_clicked)

# ---------------------------------------------------------------------------
func _on_tile_clicked(tile: Node) -> void:
	if slot_ids.size() >= 4:
		return

	var id: int = tile.tile_id

	if not game_board:
		push_error("SlotBar: game_board is null!")
		return

	# Free the previous undo tile — new click overwrites the undo slot
	if _undo_tile != null:
		game_board.discard_tile(_undo_tile)
		_undo_tile = null

	game_board.take_tile(tile)
	_undo_tile = tile  # keep node alive for potential undo
	_undo_tile.hide()  # hide it so it doesn't appear as a ghost on the board

	slot_ids.append(id)
	_update_visuals()
	_check_for_matches()

# ---------------------------------------------------------------------------
# Reset — called when loading a new level
# ---------------------------------------------------------------------------
func reset() -> void:
	if _undo_tile != null:
		game_board.discard_tile(_undo_tile)
		_undo_tile = null
	slot_ids.clear()
	_update_visuals()

# ---------------------------------------------------------------------------
# Undo — returns true if successful (caller should deduct the charge)
# ---------------------------------------------------------------------------
func undo_last() -> bool:
	if _undo_tile == null or slot_ids.is_empty():
		return false

	_undo_tile.show()  # make it visible again on the board
	game_board.restore_tile(_undo_tile)
	_undo_tile = null
	slot_ids.pop_back()
	_update_visuals()
	return true

# ---------------------------------------------------------------------------
func _check_for_matches() -> void:
	for i in range(slot_ids.size()):
		for j in range(i + 1, slot_ids.size()):
			if slot_ids[i] == slot_ids[j]:
				_handle_match(i, j)
				return

	if slot_ids.size() >= 4:
		GameManager.game_over.emit()

func _handle_match(i: int, j: int) -> void:
	var matched_id: int = slot_ids[i]
	slot_ids.remove_at(j)
	slot_ids.remove_at(i)

	# Matched tile is gone — free its node and clear the undo slot
	if _undo_tile != null:
		game_board.discard_tile(_undo_tile)
		_undo_tile = null

	GameManager.match_made.emit(null, null)
	GameManager.add_score(10)
	GameManager.damage_boss(1)

	_update_visuals()

func _update_visuals() -> void:
	for i in range(4):
		if i < slot_ids.size():
			slot_bgs[i].color   = COLOR_OCCUPIED
			slot_labels[i].text = str(slot_ids[i])
		else:
			slot_bgs[i].color   = COLOR_EMPTY
			slot_labels[i].text = ""
