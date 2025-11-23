local currentMinigame = nil
local currentDoor = nil
local currentHeistId = nil

--========================================
-- SECTION: MINIGAME CALLBACK FUNCTIONS
--========================================

function PatternSuccess()
    TriggerServerEvent("heist:server:openDoor", currentDoor)
end

function PatternFail()
    TriggerServerEvent("heist:server:Failhack", currentHeistId)
end

function TimingSuccess()
    TriggerServerEvent("heist:server:openDoor", currentDoor)
end

function TimingFail()
    TriggerServerEvent("heist:server:Failhack", currentHeistId)
end

local MinigameCallbacks = {
    startPattern = { success = PatternSuccess, fail = PatternFail },
    startTiming  = { success = TimingSuccess,  fail = TimingFail }
}

--========================================
-- SECTION: UI SETUP
--========================================

HeistUi = WebUI("Heist", "main/nui/index.html")

--========================================
-- SECTION: MINIGAME SYSTEM
--========================================

RegisterClientEvent("heist:client:startMinigame", function(data)
    currentMinigame = data.minigame
    currentDoor = data.door
    currentHeistId = data.heistId

    StartMinigame(currentMinigame)
end)

HeistUi:RegisterEventHandler("CloseMenu", function()
    HeistUi:SetInputMode(0)
    HeistUi:SendEvent("close")
    currentMinigame = nil
end)

HeistUi:RegisterEventHandler("onHackSuccess", function()
    HeistUi:SetInputMode(0)
    HeistUi:SendEvent("close")

    if MinigameCallbacks[currentMinigame] then
        MinigameCallbacks[currentMinigame].success()
    end

    currentMinigame = nil
end)

HeistUi:RegisterEventHandler("onHackFail", function()
    HeistUi:SetInputMode(0)
    HeistUi:SendEvent("close")

    if MinigameCallbacks[currentMinigame] then
        MinigameCallbacks[currentMinigame].fail()
    end

    currentMinigame = nil
end)

function StartMinigame(type)
    currentMinigame = type
    HeistUi:SendEvent(type)
    HeistUi:SetInputMode(1)
    HeistUi:BringToFront()
    HeistUi:SetStackOrder(23)
end

--========================================
-- SECTION: PHONE NOTIFICATION SYSTEM
--========================================

RegisterClientEvent("heist:client:notify", function(data)
    HeistUi:SendEvent("notify", {
        message = data.text,
        color = data.color,
        duration = data.duration
    })
end)

--========================================
-- SECTION: CLEANUP
--========================================

function onShutdown()
    HeistUi:Destroy()
end
