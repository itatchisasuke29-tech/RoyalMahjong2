# AGENTS.md — Master Plan for Royal Mahjong

## Project Overview
**App:** Royal Mahjong
**Goal:** A calming, relaxing game that reduces user anxiety while offering an engaging storyline and puzzles.
**Stack:** Godot Engine 4 (GDScript), 2D Mobile renderer
**Current Phase:** Phase 1 — Foundation

## How I Should Think
1. **Understand Intent First**: Before answering, identify what the user actually needs
2. **Ask If Unsure**: If critical information is missing, ask before proceeding
3. **Plan Before Coding**: Propose a plan, ask for approval, then implement
4. **Verify After Changes**: Run tests/linters or manual checks after each change
5. **Explain Trade-offs**: When recommending something, mention alternatives

## Plan → Execute → Verify
1. **Plan:** Outline a brief approach and ask for approval before coding.
2. **Plan Mode:** If supported, use a Plan/Reflect mode for this step.
3. **Execute:** Implement one feature at a time.
4. **Verify:** Run tests/linters or manual checks after each feature; fix before moving on.

## Context & Memory
- Treat `AGENTS.md` and `agent_docs/` as living docs.
- Use persistent tool configs (`CLAUDE.md`) for project rules.
- Update these files as the project scales (commands, conventions, constraints).

## Optional Roles (If Supported)
- **Explorer:** Scan codebase or docs in parallel for relevant info.
- **Builder:** Implement features based on the approved plan.
- **Tester:** Run tests/linters and report failures.

## Testing & Verification
- Follow `agent_docs/testing.md` for test strategy.
- If no tests exist, propose minimal checks before proceeding.
- Do not move forward when verification fails.

## Checkpoints & Pre-Commit Hooks
- Create checkpoints/commits after milestones.
- Ensure pre-commit hooks pass before commits.

## Context Files
Refer to these for details (load only when needed):
- `agent_docs/tech_stack.md`: Tech stack & libraries
- `agent_docs/code_patterns.md`: Code style & patterns
- `agent_docs/project_brief.md`: Persistent project rules and conventions
- `agent_docs/product_requirements.md`: Full PRD
- `agent_docs/testing.md`: Verification strategy and commands

## Current State (Update This!)
**Last Updated:** 2026-02-21
**Working On:** Initializing project setup and core features
**Recently Completed:** None
**Blocked By:** None

## Roadmap
### Phase 1: Foundation (Week 1)
- [ ] Initialize Godot 4 project with Mobile renderer.
- [ ] Implement robust valid pair checking and grid layer logic.
- [ ] Build 4-slot bar UI and check logic.
- [ ] Parse JSON level data.

### Phase 2: Core Features (Week 2)
- [ ] Implement Simple JSON State Machine for meta-game.
- [ ] Boss health functionality (Wait for tile hits).
- [ ] Admob/AppLovin integration (Rewarded Ads for Shuffles/Undos).
- [ ] Final UI Polish with Midjourney assets.

## What NOT To Do
- Do NOT delete files without explicit confirmation
- Do NOT modify database schemas without backup plan
- Do NOT add features not in the current phase
- Do NOT skip tests for "simple" changes
- Do NOT bypass failing tests or pre-commit hooks
- Do NOT use deprecated libraries or patterns

## Engineering Constraints

### Type Safety (No Compromises)
- Enable typed GDScript (e.g., `var count: int = 0`, `func my_func() -> void:`).

### Architectural Sovereignty
- Logic and state management should exist via Autoloads (Singletons) or clear parent nodes.
- Do not tightly couple UI elements to game mechanics directly. Use Godot Signals.

### The "No Apologies" Rule
- Do NOT apologize for errors—fix them immediately
- Do NOT generate filler text before providing solutions
- If context is missing, ask ONE specific clarifying question
