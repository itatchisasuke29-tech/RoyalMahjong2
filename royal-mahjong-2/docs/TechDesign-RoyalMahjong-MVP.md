# Technical Design Document: Royal Mahjong MVP

## How We'll Build It

### Recommended Approach: Godot Engine (GDScript)

Based on your requirements (2-week timeline, AI-assisted coding, complex tile layering, mobile platform), here's the optimal path:

**Primary Recommendation: Godot Engine 4 (GDScript) with AI Assistance (Claude 3.7 / Cursor)**
- **Why it's perfect for you:** 
  1. Godot's node system natively handles the Z-indexing and complex layering required for a Mahjong game effortlessly compared to React Native or Web frameworks. 
  2. GDScript is Python-like, making it extremely readable and easy for AI models (like Claude 3.7) to generate correctly. 
  3. One-click export to both iOS and Android without needing to rewrite UI layers.
  4. Native particle systems and animation players make "juicy" match feedback easy to implement for a vibe-coder without complex math.
- **What it costs:** 100% Free and Open Source. No royalties.
- **Time to learn:** Low. The node hierarchy is visual, so you can see your layers without reading code.
- **Limitations to know:** Setting up plugins (like ad networks) can be slightly more manual than an ecosystem like Expo (React Native), requiring specific Godot plugins for mobile ads.

### Alternative Options Compared

| Option | Pros | Cons | Cost | Time to MVP |
|--------|------|------|------|-------------|
| **React Native (Expo + Skia)** | Easy to set up UI, huge AI knowledge base (easy for ChatGPT/Claude to write) | Handling Z-indexing of hundreds of layered tiles in Skia can be painfully slow and complex to code. | Free | 2-3 Weeks |
| **Unity (C#)** | Industry standard, robust asset store for mobile games | Bloated, C# can be overly verbose for simple vibe-coding, slower iteration time. | Free tier | 3-4 Weeks |

---

## Game Mechanics & Balance

### Match-2 with 4-Slot Bar
A 4-slot bar for a Match-2 game creates a highly tactical, slower-paced experience compared to Match-3.
- **Why it works for Seniors:** It reduces cognitive overload. They only need to look for two identical tiles instead of three. The 4-slot bar means they can make exactly **one mistake** (holding two unmatched tiles) while making their next match. It's forgiving but requires intention.
- **Balance Tip:** Keep the tile variety lower than a standard Mahjong game to offset the strict 4-slot limit.

### Unsolvable State Detection (The Simple Approach)
Instead of running a complex backtracking algorithm (which is slow and hard to debug), use the **"Valid Pair Check"**:
1. Scan the board to find all "Clickable" (unblocked) tiles.
2. If there are no two clickable tiles with the same ID, and the player doesn't have a matching tile in their 4-slot bar, the state is unsolvable.
3. *Action:* Automatically shuffle the board (labeled as "Emperor's Blessing" to make it a positive event) or prompt the user to use a Shuffle item.

---

## Meta-Game Implementation

### "Save the Emperor" Data Layer
For a 2-week MVP, **do not use a local database (like SQLite)**. It adds unnecessary complexity and potential AI hallucinations.
- **Solution:** A Simple JSON State Machine (or Godot Resource `Dictionary` saved to a `.json` / `.cfg` file).
- **Structure:**
```json
{
  "current_level": 5,
  "emperor_state": "on_fire",  // Drives the visual asset on the screen
  "total_coins": 1500,
  "powerups": {"undo": 3, "shuffle": 1}
}
```

### Boss Battles Linked to Tile Matches
- Give the boss an HP pool (e.g., 20 HP).
- Every successful Match-2 triggers a projectile animation from the matched tiles to the boss, subtracting 1 HP. 
- *Vibe-coder implementation:* In Godot, emit a signal `match_made` that the Boss Node listens to and plays a "damage taken" animation while reducing its `current_hp` variable.

---

## Asset Pipeline (AI First)

To create a consistent "Royal Chinese/Asian" aesthetic that is accessible to seniors:

1. **AI Art Model:** **Midjourney v6** is best for consistent, high-quality rendering. Use the `--cref` (character reference) tool to keep the Emperor looking the same across his states (happy, scared, etc.).
2. **UI (Bamboo/Gold):** 
   - *Prompt format:* `Mobile game UI asset, wooden bamboo border with gold ingot accents, flat design, clean vector style, high quality --v 6.0`
3. **Tile Sets for Seniors (Accessibility):**
   - High contrast is crucial. Ensure symbols on the tiles take up 80% of the tile face.
   - Avoid intricate traditional characters if they blur at small sizes. Use clear iconography (e.g., distinct coins, bamboo sticks, dragons).
   - *Prompt format:* `Mahjong tile top-down view, isolated on white background, distinct red dragon symbol, high contrast, clean vector style, mobile game asset --v 6.0`

---

## Monetization for Seniors

**Ethical and Clear Monetization:**
- **Rewarded Video Ads (Primary):** "Watch an ad to get 2 Shuffles." Seniors are highly likely to watch rewarded ads if the value proposition is clear and it helps them overcome a frustrating moment without spending money.
- **Interstitial Ads:** Place these **only between levels**, never interrupting gameplay. Ensure the "X" button to close the ad is standard and not a trick (Apple/Google guidelines will enforce this, but prioritize ad networks that restrict misleading interstitials).
- **IAP (In-App Purchases):** Sell bundles of "Undos" and "Shuffles". Frame them as "Royal Assists". Make the purchase button large and distinct, with clear pricing ($1.99, $4.99) so there are no accidental clicks.

---

## 2-Week Execution Roadmap

**Week 1: Core Loop & Mechanics**
- **Day 1-2 (Foundation):** Set up Godot 4. Implement basic Tile rendering, Z-indexing (layered layouts).
- **Day 3 (Clicking & Logic):** Implement the raycast/click detection to determine if a tile is "blocked".
- **Day 4 (The Bar):** Implement the 4-slot bar UI and the Match-2 checking logic.
- **Day 5 (Level Generation):** Create a robust JSON layout parser to load tile formations (pyramid, turtle).
- **Day 6-7 (Polish):** Add satisfying lerp animations for tiles moving to the bar, and match particle effects.

**Week 2: Meta-Game & Launch Prep**
- **Day 8 (Meta Data Layer):** Implement the JSON save/load state machine.
- **Day 9 (The Emperor):** Add the top screen UI with the Emperor's animated sprite and dialogue box.
- **Day 10 (Boss/Disasters):** Implement boss health bars and the "Match-to-Damage" signal logic.
- **Day 11 (Monetization):** Integrate AdMob / AppLovin plugin for Godot (Rewarded/Interstitials).
- **Day 12 (Assets & UI):** Replace all placeholder art with Midjourney generated assets.
- **Day 13 (Testing):** Playtest specific edge-cases (e.g., clicking 5 tiles very fast, unsolvable boards).
- **Day 14 (Deploy):** Final build export to iOS App Store / Google Play via Xcode/Android Studio.

---

## Algorithm Snippets

### Tile Clickability Check (Layer Grid Approach)
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

### Match-2 Buffer Logic
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

---

## Project Setup Checklist

### Step 1: Create Accounts (Day 1)
- [ ] Apple Developer account — $99/yr (Required for iOS)
- [ ] Google Play Console — $25 once (Required for Android)
- [ ] AdMob or AppLovin Account (For ads)
- [ ] Midjourney Subscription (For generating high-quality art quickly)

### Step 2: AI Assistant Setup (Day 1)
- [ ] Install Cursor IDE or use Claude desktop application.
- [ ] Prepare your "System Prompt" explaining this is a Godot 4.3 GDScript project.

### Step 3: Project Initialization (Day 1)
1. Download Godot Engine 4.
2. Click "New Project".
3. Name it: "Royal Mahjong".
4. Set renderer to "Mobile" or "Compatibility" (best for 2D UI games on mobile).
5. Open Cursor, point it to the project folder, and request: "Set up a main scene with a 2D camera and a responsive canvas layer for UI."
