# 🏦 Small Bank Heist – Summary (Mini-PRD)

A simplified, modular Fleeca-style bank heist designed to demonstrate clean logic, state flow, and server-validated systems.

---

## 🔹 1. Overview

This heist includes:

- **Entry** (with minigame)
- **Vault access** (with minigame)
- **Loot interaction** (With weight system)
- **Escape validation** 
- **Basic PD response**

> **Note:** Not a full heist — only the required skeleton.

---

## 🔹 2. Heist Flow

### 1. Start Conditions
- 2–3 required items 
- Minimum 2 players ( ⚠️ There's a problem here, and I'll comment on it below! ) 
- Active cooldown check

### 2. Entry
- Door hacking
- alarm chance

### 3. Vault
- One minigame (pattern hack)
- Vault opens on success
- PD timer starts (auto-arrival)

### 4. Looting
- loot spots
- capacity restrictions

### 5. Escape
- Escape radius or lose PD
- Heist ends as success 

---

## 🔹 3. Data Model (Simplified)

```lua
Config.Heist = {
    ["bank_heist_1"] = {
        MinPlayers = 1,
        AlarmChance = 50,
        PDDelay = 30,
        PDDelayAfterVaultOpen = 90,
        startPoint = {},
        MaxWeight = 2000,
        DoorsConfig = {},
        ItemsConfig = {},
        SecurityConfig = {},
        LootsConfig = {},
        LosePoliceAndFinishConfig = {},
    }
    --- here you can create more heist !

}
```

---

## 🔹 4. State Machine

```
IDLE → PREPARED → ENTRY → VAULT → LOOTING → ESCAPE → COMPLETE
```

**Transitions driven by:**
- Requirements met
- Door breached
- Minigame success/fail
- Loot completed
- Escape or arrest

---

## 🔹 5. Server Logic

The server is responsible for:

- ✅ Validates items, player count, cooldown
- ✅ Runs minigame results (client cannot fake)
- ✅ Handles alarm + PD notification
- ✅ Generates loot server-side

---

## 🔹 6. Minigame (Example)

### Pattern Hack

| Property | Value |
|----------|-------|
| **Sequence** | 4–7 symbols |
| **Mistakes Allowed** | 3 |
| **Success** | Vault opens |
| **Failure** | Instant PD alert |

---

## 🔹 7. PD Trigger

- Silent alarm chance (e.g., 40%)
- PD receives bank location
- Auto-arrival after vault timer

---

## 🔹 8. Non-Functional Requirements

| Requirement | Description |
|-------------|-------------|
| **Modular** | Usable in any small bank |
| **Secure** | Safe from client exploits |

---

## 🔹 9. Submission

**Include:**

1. ✅ Lua implementation
2. ✅ Clean comments
3. ✅ This Markdown explanation


---



 ## ⚠️ Known Issues & Limitations

During script development, I unfortunately encountered some technical problems:

🔴 Problems Encountered

Helix Native doors (So I created a little system to simulate doors, just to make it look nice.)

Multiplayer System

I had problems with multiplayer. To save time, I implemented a solution that supports multiplayer with some slight changes to how to retrieve the player src.

⚠️ It was not possible to test with real multiplayer, only with 2 local instances. (😔)

State Persistence

Problems saving the heist state and continuing if the player leaves. The reconnection functionality during an active heist is not fully implemented.

NUI Interface

I had some problems with NUI (irrelevant to the test)


**Made with ❤️**
