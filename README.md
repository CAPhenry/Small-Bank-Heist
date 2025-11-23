🏦 Small Bank Heist – Summary (Mini-PRD)

A simplified, modular Fleeca-style bank heist designed to demonstrate clean logic, state flow, and server-validated systems.

🔹 1. Overview

This heist includes:

Entry

Vault access (with one minigame)

Loot interaction

Escape validation

Basic PD response

Not a full heist — only the required skeleton.

🔹 2. Heist Flow
1. Start Conditions

2–3 required items

Minimum 2 players

Active cooldown check

2. Entry

Door lockpick/hacking

Silent alarm chance

3. Vault

One minigame (pattern hack / drill / lockpick)

Vault opens on success

PD timer starts (auto-arrival)

4. Looting

1–2 loot spots

Time or capacity restrictions

5. Escape

Escape radius or lose PD

Heist ends as success or failure

🔹 3. Data Model (Simplified)
Config.Heist = {
    cooldown = 1800,
    requiredPlayers = 2,
    requiredItems = { "drill", "electronic_kit", "keycard" },

    timers = {
        vaultPD = 120,
        escape = 90
    },

    loot = {
        cash = { min = 2000, max = 5000 },
        jewels = { min = 1, max = 3 }
    }
}

🔹 4. State Machine
IDLE → PREPARED → ENTRY → VAULT → LOOTING → ESCAPE → COMPLETE


Transitions driven by:

Requirements met

Door breached

Minigame success/fail

Loot completed

Escape or arrest

🔹 5. Server Logic

Validates items, player count, cooldown

Runs minigame results (client cannot fake)

Handles alarm + PD notification

Generates loot server-side

Maintains heist state across disconnects

🔹 6. Minigame (Example)

Pattern Hack

4–7 symbol sequence

10s limit

2 mistakes allowed

Success → vault opens

Failure → instant PD alert

🔹 7. PD Trigger

Silent alarm chance (e.g., 40%)

Loud alarm on minigame fail

PD receives bank location + alarm type

Auto-arrival after vault timer

🔹 8. Non-Functional Requirements

Modular (usable in any small bank)

Safe from client exploits

Reload-safe (server stores state)

🔹 9. Submission

Include:

Lua implementation

Clean comments

This Markdown explanation

Optional screenshots/GIFs
