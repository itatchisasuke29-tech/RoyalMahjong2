# Testing Strategy

- **Manual/Playtest Checks:**
  - Verify Z-indexing: Are tiles properly layered with correct shadows?
  - Verify Block Logic: Players absolutely cannot click a tile that has another directly above it, or is blocked on BOTH left and right sides.
  - Test the Bar: Can you only add up to 4 tiles? Does matching erasing properly? 
  - Test Shuffling: When zero possible valid moves exist on the board AND the 4-slot bar doesn't have a tile that could match, force an auto-shuffle ("Emperor's Blessing").
- **Edge cases:** Clicking 5 tiles very rapidly should still cap at 4 in the slot bar. 
- **Pre-commit Hooks:** Usually none in simple Godot projects, rely on GDScript parser warnings.
- **Verification Loop:** Run checks (F5) after each feature implementation and fix Godot debugger red errors instantly.
