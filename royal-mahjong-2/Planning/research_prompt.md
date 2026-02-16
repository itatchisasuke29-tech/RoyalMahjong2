# Deep Research Request: Royal Mahjong

<context>
I'm a founder building **Royal Mahjong**, a mobile game targeting seniors (specifically approaching the Asian demographic).
**The Core Concept**: A "Match-2" tile solitaire game with a 4-slot holding bar.
**The Meta-Game**: "Save the Emperor" story progression (fixing disasters like fires/floods) and Boss Battles every 10 levels.
**Timeline**: Extremely aggressive 2-week MVP build using AI coding tools (Claude/Cursor/Antigravity).
**Budget**: Low for dev (using AI), High ($10k) for marketing/ads.
</context>

<instructions>
### Key Objectives
I need a concrete execution plan to build this **in 2 weeks** using AI tools.

### Key Questions to Answer:

1.  **Game Mechanics & Balance**:
    *   Analyze the **"Match-2 with 4-slot bar"** mechanic vs the standard "Match-3 with 7-slot bar" (e.g., *Zen Match*). Is 4 slots too punishing or too easy for seniors?
    *   How do top games (Vita Mahjong) handle "unsolvable state" detection? (I need the simplest algorithm to ensure levels are beatable).

2.  **Technical Stack for Speed (2-Week Deadline)**:
    *   Recommend the **fastest** stack to build a cross-platform (iOS/Android) 2D puzzle game using AI code generation.
    *   Compare **Godot (GDScript)** vs **React Native (Skia/Reanimated)** vs **Unity (C#)** specifically for how well AI models (Claude 3.7/Sonnet) generate code for them.
    *   *Constraint*: Must support complex "layering" of tiles (z-indexing) and smooth animations.

3.  **Meta-Game Implementation**:
    *   How to structure the "Save the Emperor" data layer? (Simple JSON state machine vs local database).
    *   What is the simplest way to implement "Boss Health" linked to "Tile Matches"?

4.  **Asset Pipeline (AI First)**:
    *   Which AI art models (Midjourney/Flux/Stable Diffusion) are best for consistent "Royal Chinese/Asian" varying aesthetics for:
        *   UI (Bamboo borders, gold ingots)
        *   Character Sprites (The Emperor in different states: happy, scared, drowning)
        *   Tile Sets (High contrast for seniors)

5.  **Monetization for Seniors**:
    *   Best practices for ad placement that doesn't confuse older users (Interstitial vs Rewarded).
    *   Ethical IAP strategies for "Undo/Shuffle" powerups.

### Required Deliverables:
1.  **2-Week Execution Roadmap**: Day-by-day breakdown of what to prompt/code (Day 1: Core Mechanics, Day 2: Tile Logic, etc.).
2.  **Tech Stack Verdict**: The single best engaging and easiest-to-debug stack for this specific game type.
3.  **Algorithm Snippets**: Pseudocode logic for the "Match-2 buffer" and "Tile Clickability Check" (raycast vs layer grid).
4.  **Competitor Deconstruct**: What *Royal Kingdom* and *Vita Mahjong* do that keeps seniors retained (specifically UI/UX patterns).
</instructions>

<output_format>
- **Prioritize Speed**: Every recommendation must filter for "Can I build this with AI in 2 weeks?"
- **Code-First Approach**: Provide logic examples for the core matching mechanic.
- **Visuals**: Describe the UI layout for the 4-slot bar to maximize accessibility for seniors.
- **Cite Sources**: Link to developer logs or deconstructions of similar puzzle mechanics.
</output_format>
