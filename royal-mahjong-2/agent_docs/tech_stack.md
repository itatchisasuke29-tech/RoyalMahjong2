# Tech Stack & Tools
- **Engine:** Godot Engine 4 (GDScript)
- **Renderer:** 2D Mobile or Compatibility mode
- **Target OS:** iOS and Android
- **Monetization:** AdMob / AppLovin Plugin for Godot 
- **Art/Assets:** Midjourney v6 (`--cref` for consistent character generation for Emperor states).

## Error Handling
```gdscript
# Example error handling pattern with JSON parsing
var json = JSON.new()
var error = json.parse(json_string)
if error == OK:
    var data_received = json.data
else:
    push_error("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
```

## Core Mechanics Sandbox
### 1. Tile Clickability Check (Layer Grid Approach)
*Instead of complex Physics Raycasts, use a Grid system for Mahjong.* Every tile has an `(x, y, z)` coordinate.

```gdscript
# Pseudocode for checking if a tile can be clicked
func is_tile_free(tile) -> bool:
    # 1. Check if ANY tile is directly above it (higher Z)
    if grid.has_tile_at(tile.x, tile.y, tile.z + 1):
        return false
        
    # 2. Check left/right blockers (same Z)
    var blocked_left = grid.has_tile_at(tile.x - 1, tile.y, tile.z)
    var blocked_right = grid.has_tile_at(tile.x + 1, tile.y, tile.z)
    
    # Free if at least one side is completely open
    if not blocked_left or not blocked_right:
        return true
        
    return false
```

### 2. Match-2 Buffer Logic
```gdscript
# Pseudocode for the 4-slot bar match logic
var slot_bar = [] # Max 4 items

func on_tile_clicked(tile):
    if slot_bar.size() >= 4:
        return # Bar is full, ignore click
        
    # Move tile to bar
    slot_bar.append(tile)
    animate_move_to_bar(tile)
    
    check_for_matches()

func check_for_matches():
    # Iterate through the bar to find a pair
    for i in range(slot_bar.size()):
        for j in range(i + 1, slot_bar.size()):
            if slot_bar[i].id == slot_bar[j].id:
                # We found a Match-2!
                handle_match(slot_bar[i], slot_bar[j])
                return

func handle_match(tile1, tile2):
    # Remove from bar array
    slot_bar.erase(tile1)
    slot_bar.erase(tile2)
    
    # Fire off animations/boss damage signals
    play_match_particles(tile1, tile2)
    emit_signal("deal_boss_damage", 1)
```

## Data Management
A Simple JSON State Machine for Meta-Game:
```json
{
  "current_level": 5,
  "emperor_state": "on_fire",
  "total_coins": 1500,
  "powerups": {"undo": 3, "shuffle": 1}
}
```

## Naming Conventions
- Signals: `snake_case` (e.g., `deal_boss_damage`)
- Classes/Nodes: `PascalCase`
- Variables/Functions: `snake_case`
