-- Stores the start trigger actors for each heist
local HeistStartTriggers = {}

-- Tracks which heist a player is inside the start zone of
local PlayerInsideStart = {}  


--========================================================
-- SECTION: INPUT HANDLING
--========================================================

-- Bind the "E" key to start a heist when inside the trigger area
Input.BindKey('E', function()
    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)

    -- Check if the player is inside any heist start area
    local heistId = PlayerInsideStart[src]
    if not heistId then
        return 
    end

    -- Prevent starting a heist if one is already active
    if HeistManager.current then
        Notify(src, "Are you crazy? There's already an active heist!", "#ff0000ff", 5000)
        return
    end

    -- Start the heist the player is standing in
    startHeist(heistId)
end)



--========================================================
-- SECTION: HEIST START TRIGGERS
--========================================================

-- Creates all start triggers defined in the config
function createStartHeistTriggers()
    for heistId, cfg in pairs(Config.Heists) do
        if cfg.startPoint then

            -- Destroy old trigger if it exists to avoid duplicates
            if HeistStartTriggers[heistId] then
                HeistStartTriggers[heistId]:K2_DestroyActor()
            end

            -- Create the trigger volume the player must stand in to start the heist
            local trigger = Trigger(
                cfg.startPoint.position,
                Rotator(0,0,0),
                cfg.startPoint.size or Vector(200),
                TriggerType.Sphere,
                true,

                -- On overlap: player enters start zone
                function(self, other)
                    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
                    PlayerInsideStart[src] = heistId

                    -- Prompt player to press E
                    Notify(
                        src,
                        "Press [E] to start the heist: " .. cfg.startPoint.text,
                        "#00ff88",
                        4000
                    )
                end,

                -- Trigger color (debug only)
                Color(0, 1, 0, 0.3)
            )

            -- Detect player leaving the trigger area
            local triggerShape = trigger:K2_GetComponentsByClass(UE.UShapeComponent)
            if triggerShape[1] then
                triggerShape[1].OnComponentEndOverlap:Add(HWorld, function(_)
                    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
                    PlayerInsideStart[src] = nil -- Remove flag when player exits
                end)
            end

            -- Store reference so triggers can be cleaned later
            HeistStartTriggers[heistId] = trigger
        end
    end
end



--========================================================
-- SECTION: FINISH HEIST TRIGGER
--========================================================

-- Creates the trigger used to finish heist (after losing police, etc.)
function createLosePoliceAndFinishHeistTrigger(cfg)

    -- Remove previous end trigger if it exists
    if HeistManager.current.LosePoliceAndFinishTrigger then
        HeistManager.current.LosePoliceAndFinishTrigger:K2_DestroyActor()
    end

    -- Create new finish trigger
    local trigger = Trigger(
        cfg.position,
        cfg.rotator,
        cfg.size,
        TriggerType.Sphere,
        true,

        -- On overlap: check if player is a participant and finish heist
        function(self, other)
            local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)

            -- Prevent non-participants from finishing the heist
            if not (HeistManager.current and HeistManager.current.participants[src]) then
                Notify(src, "You are not participating in this heist!", "#ff4444", 3000)
                return
            end

            -- Player successfully reaches end trigger
            finishHeist(src)
        end,

        Color(1, 0, 0, 0.5)
    )

    -- Store reference for later cleanup
    HeistManager.current.LosePoliceAndFinishTrigger = trigger
end
