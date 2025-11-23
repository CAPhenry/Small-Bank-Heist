HeistCooldown = {}

HeistManager = {
    current = nil,
    props = {},
    doors = {},
    players = {
        items = {},
        loot = {},
        weight = {},
        participants = {},
    },
}

-- Optional: state-specific functions
HeistStates = {
    PREPARED = function() end,
    ENTRY = function() end,
    VAULT = function() end,
    LOOTING = function() end,
    FINISHED = function() end,
    FAILED = function() end
}

-- If you want to add a failure flow later:
-- function FailHeist(src, reason)
--     SetHeistState("FAILED")
--     HeistManager.players.weight[src] = nil
--     HeistManager.players.items[src] = nil
--     HeistManager.players.loot[src] = nil
--     onShutdown()
--     HeistManager.current = nil
-- end

function OnEntryDoorOpened()
    if HeistManager.current.state == "PREPARED" then
        SetHeistState("ENTRY")
    end
end

function OnVaultDoorOpened()
    SetHeistState("VAULT")
    HeistManager.current.vaultOpenAt = os.time()
    StartPDTimerForVault(HeistManager.current.id)

    -- Switch to looting a bit later
    Timer.SetTimeout(function()
        SetHeistState("LOOTING")
        Notify(src, "Safe is open! Grab everything you can, move fast!", "#00ff00", 4000)
    end, 2000)
end

function finishHeist(src)
    if not HeistManager.current then return end
    if not HeistManager.current.participants[src] then return end

    HeistCooldown[HeistManager.current.id] = os.time() + Config.Cooldown

    print("\n===== HEIST COMPLETED =====")
    print("Heist:", HeistManager.current.id)
    print("Player:", src)

    local reward = 0
    local loots = HeistManager.players.loot[src] or {}

    print("Items collected:")
    for _, loot in ipairs(loots) do
        print(string.format(" - %s | value=%d | weight=%d", loot.id, loot.value, loot.weight))
        reward = reward + loot.value
    end

    GivePlayerMoney(src, reward)
    Notify(src, "HAHAHA, we did it! See you soon!", "#00ff00", 4000)

    -- Clean player data
    HeistManager.players.items[src] = nil
    HeistManager.players.weight[src] = nil
    HeistManager.players.loot[src] = nil

    onShutdown()
    HeistManager.current = nil

    print("Heist successfully completed and cleaned up!")
end

function SetHeistState(state)
    HeistManager.current.state = state
    print("[HEIST] State changed:", state)

    if HeistStates[state] then
        HeistStates[state]()
    end
end

function onShutdown()
    -- Destroy props
    for id, data in pairs(HeistManager.props) do
        if data.actor then data.actor:K2_DestroyActor() end
        if data.interactor then data.interactor:K2_DestroyActor() end
    end

    -- Destroy doors
    for id, data in pairs(HeistManager.doors) do
        if data.actor then data.actor:K2_DestroyActor() end
    end

    HeistManager.props = {}

    -- Destroy optional trigger
    if HeistManager.current and HeistManager.current.LosePoliceAndFinishTrigger then
        HeistManager.current.LosePoliceAndFinishTrigger:K2_DestroyActor()
        HeistManager.current.LosePoliceAndFinishTrigger = nil
    end

    cleanupParticipants()
end

function cleanupParticipants()
    if HeistManager.current and HeistManager.current.participants then
        for src, _ in pairs(HeistManager.current.participants) do
            HeistManager.players.items[src] = nil
            HeistManager.players.loot[src] = nil
            HeistManager.players.weight[src] = nil
        end
    end
end
