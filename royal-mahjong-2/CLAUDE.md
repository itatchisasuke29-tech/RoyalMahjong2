# CLAUDE.md — Claude Code Configuration for Royal Mahjong

## Project Context
**App:** Royal Mahjong
**Stack:** Godot Engine 4 (GDScript)
**Stage:** MVP Development
**User Level:** Vibe-coder (A) — User guides and tests, AI handles coding.

## Directives
1. **Master Plan:** Always read `AGENTS.md` first. It contains the current phase and tasks.
2. **Documentation:** Refer to `agent_docs/` for tech stack details, code patterns, and testing guides.
3. **Plan-First:** Propose a brief plan and wait for approval before coding.
4. **Incremental Build:** Build one small feature at a time. Test frequently in Godot.
5. **No Linting:** Do not act as a linter. Utilize Godot's built-in script warnings.
6. **Communication:** Be concise. Your user is a Vibe-coder. Avoid deep architectural jargon when simple instructions will do. Tell the user *exactly* what nodes to create, where to attach scripts, and what settings to expose.

## The "No Apologies" Rule
- Do NOT apologize for errors—fix them immediately.
- Do NOT generate filler text before providing solutions.
- If context is missing, ask ONE specific clarifying question.
