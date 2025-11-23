-- Event triggered when the player fails a hacking minigame
RegisterServerEvent("heist:server:Failhack", function(src, heistId)
    triggerAlarm(heistId, src)
end)


-- Triggers the alarm system based on chance and sends police notification after delay
function triggerAlarm(heistId, src)
    local cfg = Config.Heists[heistId]
    local chance = math.random(100)

    -- If random chance is within alarm probability, alarm goes off
    if chance <= cfg.AlarmChance then
        Notify(src, "Damn, man, I think they called the police, hurry up!!!", "#ff0000ff", 4000)

        -- After X seconds, notify the police
        Timer.SetTimeout(function()
            NotifyPolice(heistId)
        end, cfg.PDDelay * 1000)
    end
end


-- Starts a police timer specifically after the vault door is opened
function StartPDTimerForVault(heistId)
    local cfg = Config.Heists[heistId]

    Timer.SetTimeout(function()
        NotifyPolice(heistId)
    end, cfg.PDDelayAfterVaultOpen * 1000)
end


-- Sends an alert event to police systems indicating an active heist
function NotifyPolice(heistId)
    local cfg = Config.Heists[heistId]

    -- Here you would integrate with your police alert system
    -- Example (commented out because depends on your framework or scripts):
    -- TriggerEvent("police:server:alert", {
    --     type = "bank_heist",
    --     state = HeistManager.current.state,
    --     timestamp = os.time(),
    --     location = cfg.startPoint.position,
    -- })
end
