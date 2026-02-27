extends Node2D

# ---------------------------------------------------------------------------
# GameBoard — Grid management, level loading, tile state logic
# Attached to: scenes/GameBoard.tscn
# ---------------------------------------------------------------------------

@export var tile_scene: PackedScene
@export var tile_spacing:    Vector2 = Vector2(130.0, 160.0)  # gap between tiles
@export var z_visual_offset: Vector2 = Vector2(-8.0, -10.0)   # pixel shift per Z layer

@onready var tile_container: Node2D = $TileContainer

# Core grid: Vector3i(x, y, z) → Tile node
var grid: Dictionary = {}

# tile_id (int) → name (String), loaded from level JSON
var _tile_types: Dictionary = {}

# ---------------------------------------------------------------------------
# Level Loading
# ---------------------------------------------------------------------------
func load_level(json_path: String) -> void:
	grid.clear()
	for child in tile_container.get_children():
		child.queue_free()

	var file := FileAccess.open(json_path, FileAccess.READ)
	if not file:
		push_error("GameBoard: cannot open level file: " + json_path)
		return

	var json := JSON.new()
	var err  := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("GameBoard: JSON parse error — " + json.get_error_message())
		return

	var data: Dictionary = json.data

	# Build int-keyed tile_types map
	_tile_types.clear()
	var raw_types: Dictionary = data.get("tile_types", {})
	for key in raw_types:
		_tile_types[int(key)] = raw_types[key]

	GameManager.level_name = data.get("name", "")
	GameManager.set_boss(data.get("boss_name", "Boss"), data.get("boss_hp", 10))

	for tile_data in data["tiles"]:
		_spawn_tile(tile_data["id"], tile_data["x"], tile_data["y"], tile_data["z"])

	refresh_tile_states()

func _spawn_tile(id: int, gx: int, gy: int, gz: int) -> void:
	if not tile_scene:
		push_error("GameBoard: tile_scene is not assigned!")
		return

	var tile: Node = tile_scene.instantiate()
	tile_container.add_child(tile)

	# Convert grid coords → world position with Z layer visual offset
	tile.position = Vector2(
		gx * tile_spacing.x + gz * z_visual_offset.x,
		gy * tile_spacing.y + gz * z_visual_offset.y
	)

	var tile_name: String = _tile_types.get(id, "?")
	tile.setup(id, tile_name, gx, gy, gz)
	grid[Vector3i(gx, gy, gz)] = tile

# ---------------------------------------------------------------------------
# Tile State — which tiles are clickable?
# ---------------------------------------------------------------------------
func is_tile_free(tile: Node) -> bool:
	# Blocked from above (same x,y but z+1 exists)
	if grid.has(Vector3i(tile.grid_x, tile.grid_y, tile.grid_z + 1)):
		return false

	# Blocked on both left and right (same z)
	var blocked_left:  bool = grid.has(Vector3i(tile.grid_x - 1, tile.grid_y, tile.grid_z))
	var blocked_right: bool = grid.has(Vector3i(tile.grid_x + 1, tile.grid_y, tile.grid_z))

	# Free if at least one horizontal side is open
	return not blocked_left or not blocked_right

func refresh_tile_states() -> void:
	for key: Vector3i in grid:
		grid[key].set_free(is_tile_free(grid[key]))

# ---------------------------------------------------------------------------
# Input — manual hit-test (replaces Area2D input_event, no special settings needed)
# ---------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return

	var mouse_pos: Vector2 = tile_container.get_local_mouse_position()
	var best_tile: Node = null
	var best_z: int = -1

	for key: Vector3i in grid:
		var tile: Node = grid[key]
		if not tile.is_free:
			continue
		var diff: Vector2 = mouse_pos - tile.position
		if abs(diff.x) <= 60.0 and abs(diff.y) <= 75.0:
			if tile.grid_z > best_z:
				best_tile = tile
				best_z = tile.grid_z

	if best_tile:
		GameManager.tile_clicked.emit(best_tile)
		get_viewport().set_input_as_handled()

# ---------------------------------------------------------------------------
# Tile Removal (two-step so SlotBar can animate before freeing)
# ---------------------------------------------------------------------------

# Step 1: remove from grid + refresh (keeps the node alive for bar animation)
# current_slot_ids = IDs already in the slot bar BEFORE this tile is added
func take_tile(tile: Node, current_slot_ids: Array = []) -> void:
	grid.erase(Vector3i(tile.grid_x, tile.grid_y, tile.grid_z))

	if grid.is_empty():
		GameManager.board_cleared.emit()
		return

	refresh_tile_states()

	# Build the full "reachable" pool: free board tiles + slot bar + this new tile
	var check_ids: Array = current_slot_ids.duplicate()
	check_ids.append(tile.tile_id)
	if not has_valid_move(check_ids):
		_auto_shuffle()

# Step 2: free the node (called by SlotBar after match animation)
func discard_tile(tile: Node) -> void:
	tile.queue_free()

# Convenience: take + discard in one call (used by auto-shuffle internally)
func remove_tile(tile: Node) -> void:
	take_tile(tile)
	tile.queue_free()

# Restore a tile that was taken (used by Undo powerup)
func restore_tile(tile: Node) -> void:
	grid[Vector3i(tile.grid_x, tile.grid_y, tile.grid_z)] = tile
	refresh_tile_states()

# Player-triggered shuffle (same logic as auto-shuffle)
func shuffle_tiles() -> void:
	_auto_shuffle()

# ---------------------------------------------------------------------------
# Valid-move check (scans all free tiles for any matching pair)
# ---------------------------------------------------------------------------
func has_valid_move(slot_ids: Array = []) -> bool:
	var all_ids: Array = slot_ids.duplicate()
	for key: Vector3i in grid:
		if grid[key].is_free:
			all_ids.append(grid[key].tile_id)

	for i in range(all_ids.size()):
		for j in range(i + 1, all_ids.size()):
			if all_ids[i] == all_ids[j]:
				return true
	return false

# ---------------------------------------------------------------------------
# Auto Shuffle — "Emperor's Blessing" (reassigns IDs when no valid move exists)
# ---------------------------------------------------------------------------
func _auto_shuffle() -> void:

	var tiles: Array = grid.values()
	var ids:   Array = tiles.map(func(t): return t.tile_id)
	ids.shuffle()

	for i in range(tiles.size()):
		var new_name: String = _tile_types.get(ids[i], "?")
		tiles[i].setup(ids[i], new_name, tiles[i].grid_x, tiles[i].grid_y, tiles[i].grid_z)

	refresh_tile_states()
