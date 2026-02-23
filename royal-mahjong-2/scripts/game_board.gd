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

	GameManager.set_boss_hp(data.get("boss_hp", 10))

	for tile_data in data["tiles"]:
		_spawn_tile(tile_data["id"], tile_data["x"], tile_data["y"], tile_data["z"])

	refresh_tile_states()
	print("GameBoard: loaded %d tiles." % grid.size())

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

	tile.setup(id, gx, gy, gz)
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
# Tile Removal (two-step so SlotBar can animate before freeing)
# ---------------------------------------------------------------------------

# Step 1: remove from grid + refresh (keeps the node alive for bar animation)
func take_tile(tile: Node) -> void:
	grid.erase(Vector3i(tile.grid_x, tile.grid_y, tile.grid_z))

	if grid.is_empty():
		# All board tiles are now in the bar — emit after bar clears them
		GameManager.board_cleared.emit()
		print("GameBoard: board empty — level complete!")
		return

	refresh_tile_states()

	if not has_valid_move():
		_auto_shuffle()

# Step 2: free the node (called by SlotBar after match animation)
func discard_tile(tile: Node) -> void:
	tile.queue_free()

# Convenience: take + discard in one call (used by auto-shuffle internally)
func remove_tile(tile: Node) -> void:
	take_tile(tile)
	tile.queue_free()

# ---------------------------------------------------------------------------
# Valid-move check (scans all free tiles for any matching pair)
# ---------------------------------------------------------------------------
func has_valid_move() -> bool:
	var free_tiles: Array = []
	for key: Vector3i in grid:
		if grid[key].is_free:
			free_tiles.append(grid[key])

	for i in range(free_tiles.size()):
		for j in range(i + 1, free_tiles.size()):
			if free_tiles[i].tile_id == free_tiles[j].tile_id:
				return true
	return false

# ---------------------------------------------------------------------------
# Auto Shuffle — "Emperor's Blessing" (reassigns IDs when no valid move exists)
# ---------------------------------------------------------------------------
func _auto_shuffle() -> void:
	print("GameBoard: no valid moves — Emperor's Blessing! Shuffling IDs...")

	var tiles: Array = grid.values()
	var ids:   Array = tiles.map(func(t): return t.tile_id)
	ids.shuffle()

	for i in range(tiles.size()):
		tiles[i].setup(ids[i], tiles[i].grid_x, tiles[i].grid_y, tiles[i].grid_z)

	refresh_tile_states()
