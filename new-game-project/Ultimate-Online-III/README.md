# Ultimate Online III

A narrative horror RPG prototype built with **Godot 4.4**.

The project mixes:
- top-down click-to-move combat,
- in-world NPC chat dialogue,
- UI-driven psychological horror sequences,
- and branching final outcomes.

---

## Overview

In this game, the player starts in a dark fantasy map and can:

1. Explore and fight enemies (Skeletons + Demonlord boss).
2. Talk to an NPC and enter a staged dialogue flow.
3. Progress through unsettling UI events (friend request, fake login, recovery checks).
4. Trigger a final scripted sequence with good/bad ending behavior.

The experience is intentionally cinematic and story-heavy, with many timed transitions, overlays, and sound cues.

---

## Tech Stack

- **Engine:** Godot `4.4`
- **Language:** GDScript
- **Project type:** Single-player, scene-driven prototype

---

## Project Structure

```text
new-game-project/
├─ project.godot                  # Godot project configuration
├─ Scene/
│  ├─ main.tscn                   # Main world scene
│  ├─ main.gd                     # Main flow controller
│  ├─ chat_ui.tscn                # Dialogue UI scene
│  ├─ forgot_password_overlay.tscn# Horror recovery overlay
│  └─ ...
├─ Script/
│  ├─ Global.gd                   # Global lock/state singleton
│  ├─ player.gd                   # Player movement + attack
│  ├─ npc.gd                      # NPC interaction entry
│  ├─ chat_ui.gd                  # Dialogue progression logic
│  ├─ login_overlay.gd            # Fake login flow
│  ├─ friend_request.gd           # Trigger before login sequence
│  └─ final_sequence_controller.gd# Final cinematic choice sequence
├─ story.json                     # Dialogue stages and branching text
├─ demonlord.gd                   # Boss AI + death progression
└─ assets / audio / fonts / shaders
```

---

## Core Gameplay Systems

### 1) Movement & Combat
- Left-click movement.
- Enemy click-targeting with auto-approach and attack.
- 16-direction animation switching.
- Basic enemy chase and attack behavior.

### 2) Dialogue Pipeline
- Dialogue data is loaded from `story.json`.
- Stages can contain timed NPC lines and player choices.
- Branches can jump to specific stage indexes.

### 3) Global State Locking
`Global.gd` controls shared lock states:
- input lock,
- movement lock,
- chat lock,
- full freeze.

This prevents gameplay actions during cutscene/UI-heavy moments.

### 4) Horror UI Sequences
After early dialogue progression, the player is pushed into:
- friend request flow,
- forced login + connection-loss simulation,
- unsettling "forgot password" questionnaire,
- final confrontation sequence.

### 5) Ending Sequence
A final controller scene handles:
- timing events,
- gun interaction,
- bad/good ending branch behavior,
- callback into the main scene for final fade and lock.

---

## Running the Project

### Requirements
- Godot Engine **4.4** (Forward Plus enabled in project settings).

### Steps
1. Open Godot 4.4.
2. Import the project folder: `new-game-project/`.
3. Run the project from the editor.

The configured startup scene is set in `project.godot`.

---

## Notes for Contributors

- Most logic is scene-coupled and timing-based; test narrative flow in-editor after any change.
- Node path references are used heavily in scripts, so scene hierarchy changes can break runtime logic.
- Many assets are external packs/audio files; keep import metadata when moving files.

---

## Current State

This is a prototype/jam-style project focused on atmosphere and scripted flow rather than polished production architecture.

If you want to improve it next, good candidates are:
- replacing hardcoded node paths with safer references,
- separating story state into a dedicated state machine,
- adding save/checkpoint support,
- documenting branching story indexes in `story.json`.
