# Stick War Legacy-style 2D Strategy Game (Godot 4)

A single-lane, side-view 2D strategy game built in Godot 4.4. Players spend gold to spawn units that auto-advance toward the enemy base. Inspired by Stick War: Legacy.

---

## Project Structure

```
res://
├── project.godot
├── README.md
├── scripts/
│   ├── core/
│   │   ├── Global.gd          # Autoload — match state, gold, game-over
│   │   ├── SignalBus.gd       # Autoload — cross-system signal bus
│   │   └── Main.gd            # Orchestrator — spawns units, wires signals
│   ├── units/
│   │   ├── Unit.gd            # Base unit class (CharacterBody2D)
│   │   ├── UnitStats.gd       # Resource class for unit balance data
│   │   ├── Swordsman.gd       # Melee combat unit
│   │   ├── Archer.gd          # Ranged combat unit
│   │   ├── Miner.gd           # Economy unit (mine→deposit loop)
│   │   ├── Projectile.gd      # Projectile for archers
│   │   └── states/
│   │       ├── State.gd            # Base FSM state class
│   │       ├── StateMachine.gd     # Generic FSM controller
│   │       ├── IdleState.gd        # Combat idle — acquires targets
│   │       ├── MoveState.gd        # Combat advance toward target
│   │       ├── AttackState.gd      # Combat attack on cooldown
│   │       ├── DeadState.gd        # Procedural death (topple + fade)
│   │       ├── MinerMoveState.gd   # Miner travels to mine/base
│   │       ├── MineState.gd        # Miner gathers gold at mine
│   │       └── DepositState.gd     # Miner deposits gold at base
│   ├── economy/
│   │   └── Economy.gd         # Economy helper (extends Global)
│   ├── ai/
│   │   └── EnemyAI.gd         # Autonomous enemy spawn controller
│   ├── ui/
│   │   ├── UI.gd              # HUD — gold label, overlay, spawning
│   │   ├── SpawnButton.gd     # Individual spawn button with cost check
│   │   └── HealthBar.gd       # World-space draw-based health bar
│   └── base/
│       └── Base.gd            # Reusable base (player or enemy)
├── resources/
│   └── UnitStats/
│       ├── SwordsmanStats.tres
│       ├── ArcherStats.tres
│       └── MinerStats.tres
├── scenes/
│   ├── Main.tscn              # Root scene — battlefield, spawns, UI, AI
│   ├── Base.tscn              # Base scene (reused for both teams)
│   ├── Unit.tscn              # Base unit scene (inherited)
│   ├── Swordsman.tscn         # Swordsman (inherits Unit.tscn)
│   ├── Archer.tscn            # Archer (inherits Unit.tscn)
│   ├── Miner.tscn             # Miner (inherits Unit.tscn)
│   ├── Projectile.tscn        # Projectile for ranged attacks
│   ├── UI.tscn                # HUD canvas layer
│   └── HealthBar.tscn         # (not needed — HealthBar is script-only)
└── assets/
    └── (placeholder assets go here)
```

---

## How Systems Connect

### Flow Overview

1. **Main.tscn** loads as the root scene. It creates the world (bases, spawn points, containers), instantiates the UI, and adds the EnemyAI node.
2. The **UI** shows gold and spawn buttons. When pressed, **SpawnButton** deducts gold via `Global.modify_gold()` and emits `SignalBus.unit_spawned`.
3. **Main** listens to `unit_spawned`, instantiates the appropriate scene, sets its team, and adds it to the correct container.
4. Each **Unit** has a **StateMachine** that drives its behavior. Combat units cycle `Idle → Move → Attack → Dead`. Miners cycle `MinerMove → Mine → Deposit`.
5. Units acquire targets using their **AttackRange** Area2D, which detects overlapping bodies on layers 1 (units) and 4 (bases).
6. When a unit's target is in range, it attacks. Archers spawn **Projectile** nodes that home toward the target.
7. Damage reduces health. When health reaches 0, the unit transitions to the **DeadState** (procedural topple + fade via Tween).
8. When a **Base** reaches 0 health, `Global.declare_game_over()` is called, which emits `SignalBus.game_over`.
9. **UI** listens to `game_over`, shows the overlay with win/lose text and a Restart button (which works even while paused).

### Economy

- Gold is stored in `Global.player_gold` and `Global.enemy_gold` — single source of truth.
- **Miner** gathers gold at the center mine, then returns to its team's base position and calls `Global.modify_gold(team, amount)`.
- **SpawnButton** deducts player gold and emits `unit_spawned`. **EnemyAI** deducts enemy gold similarly.
- The **UI** updates the gold counter via `SignalBus.gold_changed`.

---

## Signal Map

| Signal | Emitter | Listeners | Purpose |
|---|---|---|---|
| `gold_changed(team, amount)` | `Global` (from `modify_gold`) | `UI._on_gold_changed` | Update HUD gold counter |
| `unit_spawned(team, unit, type)` | `SpawnButton`, `EnemyAI` | `Main._on_unit_spawned` | Create unit instance in world |
| `unit_died(team, unit)` | `DeadState` (via Tween finished) | (extensible — e.g., kill counter) | Notify systems a unit died |
| `unit_deposited_gold(team, amount)` | `Miner` (from `DepositState`) | (extensible) | Track economy income |
| `base_damaged(team, health, max_health)` | `Base.take_damage` | (extensible) | UI base health bar |
| `base_destroyed(team)` | `Base.destroy` | `Global.declare_game_over` | Trigger win/lose check |
| `game_over(winner)` | `Global.declare_game_over` | `UI._on_game_over` | Show game-over overlay |
| `game_restarted()` | `UI._on_restart_pressed` | `Main._on_game_restarted` | Clean up before scene reload |

---

## Collision Layer / Mask Scheme

| Layer | Bit | Value | Used By |
|---|---|---|---|
| 1 | 0 | 1 | Unit bodies (CharacterBody2D) |
| 2 | 1 | 2 | Projectiles (Area2D) |
| 3 | 2 | 4 | (unused — reserved) |
| 4 | 3 | 8 | Bases (StaticBody2D) |

### Collision Masks

| Node | Layer | Mask | Detects |
|---|---|---|---|
| Unit body | 1 | 2 | Projectiles (for damage signals) |
| Base body | 4 | 0 | Nothing (no physics push) |
| AttackRange (Area2D) | — | 1 + 8 = 9 | Units + bases for target acquisition |
| Projectile | 2 | 1 | Units (for hit detection) |

### Why Area2D for target acquisition?

Using `get_overlapping_bodies()` on an Area2D attack range leverages Godot's spatial partitioning (broadphase collision detection). This is more performant with many units than scanning `get_tree().get_nodes_in_group()` every frame. The Area2D approach also attaches naturally to each unit's physics setup — no separate manager loop needed.

---

## Difficulty Scaling Formula

The enemy AI spawns units on a timer with the following formula:

```
spawn_interval = max(min_interval, base_interval - match_time * decay_rate)
```

Where:
- `base_interval = 4.0` seconds (initial spawn interval)
- `min_interval = 1.2` seconds (fastest possible)
- `decay_rate = 0.02` (interval shrinks by 20ms per second of match time)

At match start: interval = 4.0s. After 60s: interval ≈ 2.8s. After 140s: interval = 1.2s (floor).

### Weighted Unit Selection

Unit type selection shifts over time through defined weight phases:

| Time | Miner | Swordsman | Archer |
|---|---|---|---|
| 0s | 70% | 20% | 10% |
| 30s | 40% | 40% | 20% |
| 60s | 20% | 50% | 30% |
| 120s+ | 10% | 40% | 50% |

Between phases, weights lerp smoothly. This produces early economy focus shifting to a combat-heavy army over time.

---

## FSM Architecture

The **StateMachine** is a generic Node that iterates its children looking for `State` class nodes. Each state implements:

- `enter(msg: Dictionary)` — called when entering the state
- `exit()` — called when leaving
- `update(delta)` — called every _process frame
- `physics_update(delta)` — called every _physics_process frame

States are **added as child nodes** in the scene tree. The StateMachine finds them by name (lowercased). This means:

- **Swordsman/Archer scenes** have `idle`, `move`, `attack`, `dead` child nodes
- **Miner scene** has `miner_move`, `mine`, `deposit` child nodes

Both unit types reuse the same FSM framework with different state sets — proving the architecture scales to non-combat behavior.

---

## Adding a New Unit Type

To add a 4th unit type (e.g., "Knight") with **zero changes** to Main/UI/AI:

1. **Create a stats resource** (`resources/UnitStats/KnightStats.tres`) with the balance values.
2. **Create a script** (`scripts/units/Knight.gd`) extending `Unit.gd`, overriding `do_attack()` if needed.
3. **Create a scene** (`scenes/Knight.tscn`) inheriting `Unit.tscn` with the appropriate state nodes and stats assigned.
4. **Add a SpawnButton** in `UI.tscn` for the player, or let the enemy AI discover it automatically by adding its stats and weight to `EnemyAI.gd`.

The unit base class handles targeting, health, hit feedback, death, and state machine — no changes needed there.

---

## Next Steps / Stretch Goals

### Performance
- **Object pooling** for Projectiles: when many archers fire simultaneously, pooling projectiles avoids allocation/GC churn. Pool would pre-allocate `N` projectile instances and recycle them.
- **Unit culling**: units far off-screen could skip full state updates (though for a lane game this is less critical).

### Art & Audio
- Replace `Polygon2D` placeholders with `AnimatedSprite2D` sprite sheets.
- Wire `AudioStreamPlayer2D` calls commented in attack/death/damage hooks.
- Add particle effects (hit sparks, death poof, gold pickup) via `GPUParticles2D`.

### Gameplay Extensions
- **Upgrade system**: spend gold to improve unit stats (modify the `UnitStats` resource or create upgraded tiers).
- **Waves**: define numbered waves with composition requirements rather than continuous spawning.
- **Hero units**: a unique unit per team with special abilities (unlocked at a gold threshold).
- **Tech tree**: unlock unit types over time or through investment.

### Multiplayer
- The signal-bus architecture decouples systems, making it feasible to split into authority/client roles.
- Gold and spawn commands would route through an authoritative server; `Global` would mirror state.

### UI Polish
- Unit selection indicators (click to highlight).
- Minimap or lane overview.
- Floating damage numbers.
- Tooltip on spawn buttons showing unit stats.

---

## License

MIT — see LICENSE file.
