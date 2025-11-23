--- jUST A PLACEHOLDER FUNCTION FOR EXAMPLE TO CHECK IF PLAYER HAS ALL ITEMS


function HasAllItems_List(src, items)
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return false end

    -- EXAMPLE

    -- for _, data in ipairs(items) do
    --     local itemName = data.item
    --     local needed   = data.amount
    --     local itemData = Player.Functions.GetItemByName(itemName)
    --     local has = itemData and itemData.amount or 0
    --     if has < needed then
    --         return false, itemName, needed, has
    --     end
    -- end
    return true
end

--- jUST A PLACEHOLDER FUNCTION FOR EXAMPLE TO REMOVE ITEMS FROM PLAYER


function RemoveAllItems_List(src, items)
    -- EXAMPLE
    -- local Player = exports['qb-core']:GetPlayer(src)
    -- if not Player then return false end
    -- for _, data in ipairs(items) do
    --     Player.Functions.RemoveItem(data.item, data.amount)
    -- end
    return true
end


function GivePlayerMoney(src,amount)
    -- EXAMPLE
    -- local Player = exports['qb-core']:GetPlayer(src)
    -- if not Player then return false end
    -- Player.Functions.AddMoney("bloodmoney", amount, "Bank heist")
    -- Player.Functions.AddMoney("bank", amount, "Bank heist")
    -- Player.Functions.AddMoney("cash", amount, "Bank heist")
end


--- Function to verify if has more than 1 player in area

function HasEnoughPlayersForHeist(heistId)
    local cfg = Config.Heists[heistId]
    if not cfg or not cfg.startPoint then 
        return false 
    end
    local center = cfg.startPoint.position
    local radius = cfg.startPoint.size or 300.0
    local minPlayers = cfg.MinPlayers or 1
    local playersInArea = GetPlayersInArea(center, radius)
    if #playersInArea >= minPlayers then
        return true, playersInArea
    else
        return false
    end
end


---- Function to send notify client

function Notify(src, msg, col, dur)
    TriggerClientEvent(src, "heist:client:notify", { text = msg, color = col, duration = dur or 4000 })
end