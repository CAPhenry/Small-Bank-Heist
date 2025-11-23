-- Delay the creation of start triggers by 2 seconds after the script loads
Timer.SetTimeout(function()
    createStartHeistTriggers()
end, 2000)


-- Main function to start a heist
function startHeist(heistId)

    -- Prevent starting a new heist if one is already running
    if HeistManager.current then
        Notify(src, "There's already a heist going on.", "#ff4444")
        return
    end

    -- Clean up any previous leftover entities or state
    onShutdown()

    local cfg = Config.Heists[heistId]
    if not cfg then return end

    -- Get the player controller (server-side reference to player)
    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)

    -- Check if the heist is still on cooldown
    if HeistCooldown[heistId] and os.time() < HeistCooldown[heistId] then
        local left = HeistCooldown[heistId] - os.time()
        Notify(src, "Heist on cooldown for "..left.."s.", "#ff4444")
        return
    end

    -- Verify that the required number of players is inside the start area
    local playersInArea = GetPlayersInArea(cfg.startPoint.position, cfg.startPoint.radius or 300.0)
    if not playersInArea or #playersInArea < (cfg.MinPlayers or 1) then
        Notify(src, "We need more players in the field!", "#ff4444")
        return
    end

    -- Check if the heist has item requirements before starting
    local req = cfg.StartRequirements or {}
    if req.items then
        local ok, missingItem, needed, has = HasAllItems_List(src, req.ItemsConfig)

        -- Player does not have all required items
        if not ok then
            Notify(src, "You need more "..cfg.MinPlayers.." players!", "#ff4444", 4000)
            return
        end

        -- Remove required items from player inventory
        RemoveAllItems_List(src, req.ItemsConfig)
    end

    -- Notify players that the heist is now starting
    Notify(src, "OK, we're ready. Go to the warehouse to get the necessary equipment!", "#fff200", 8000)

    -- Initialize current heist data structure
    HeistManager.current = {
        id = heistId,
        state = "PREPARED", -- First heist phase
        doors = {},
        Props = {},
        participants = {}, -- Players who will participate
        LosePoliceAndFinishTrigger = nil,
        MaxWeight = cfg.MaxWeight or 1000,
    }

    -- Register participating players and initialize their inventories and weights
    for _, s in ipairs(playersInArea) do
        HeistManager.current.participants[s] = true
        HeistManager.players.items[s] = {}
        HeistManager.players.loot[s] = {}
        HeistManager.players.weight[s] = 0
    end

    -- Create heist entities (doors, items, interactions, loot, finish triggers)
    createHeistDoors(cfg.DoorsConfig)
    createHeistItems(cfg.ItemsConfig)
    createHeistInteractions(cfg.SecurityConfig, heistId)
    createHeistLoots(cfg.LootsConfig)
    createLosePoliceAndFinishHeistTrigger(cfg.LosePoliceAndFinishConfig)
end
