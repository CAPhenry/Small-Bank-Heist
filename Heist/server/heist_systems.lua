--========================================
-- SECTION: DOORS SYSTEM
--========================================

-- Creates all heist doors based on config
function createHeistDoors(doorsConfig)
    HeistManager.doors = {}

    for _, cfg in ipairs(doorsConfig) do

        -- Spawn door static mesh
        local door = StaticMesh(cfg.position, cfg.rotation, cfg.mesh, CollisionType.Normal)

        -- Set initial size/scale
        door:SetActorScale3D(cfg.initialScale)

        -- Register door in the heist manager
        HeistManager.doors[cfg.id] = {
            actor = door,
            config = cfg,
            opened = false
        }
    end
end


-- Smoothly opens a door by scaling its Y axis over time
function openDoor(doorId)
    local data = HeistManager.doors[doorId]
    if not data then
        print("Door not found:", doorId)
        return
    end

    if data.opened then return end
    data.opened = true

    local door = data.actor
    local cfg = data.config

    local currentY = cfg.initialScale.Y
    local targetY = cfg.openScaleY
    local intervalId

    -- Interval animation for door opening
    intervalId = Timer.SetInterval(function()
        currentY = currentY - cfg.speed

        -- Stop animation once target is reached
        if currentY <= targetY then
            currentY = targetY
            Timer.ClearInterval(intervalId)
        end

        -- Apply new scale
        door:SetActorScale3D(Vector(cfg.initialScale.X, currentY, cfg.initialScale.Z))
    end, cfg.interval)
end


-- Event that opens a door from the client request
RegisterServerEvent("heist:server:openDoor", function(src, doorId)
    if not HeistManager.current then return end

    local doorData = HeistManager.doors[doorId]
    if not doorData then return end

    openDoor(doorId)

    -- If door has a specific role in heist flow, handle state progression
    local role = doorData.config.role
    if role then
        HandleDoorRole(role)
    end
end)


-- Handles special logic depending on the door role
function HandleDoorRole(role)
    if     role == "ENTRY_DOOR" then OnEntryDoorOpened()
    elseif role == "VAULT_DOOR" then OnVaultDoorOpened()
    elseif role == "EXIT_DOOR"  then OnExitDoorOpened()
    end
end



--========================================
-- SECTION: ITEMS SYSTEM (REQUIRED ITEMS)
--========================================

-- Creates all items the players must collect before the heist
function createHeistItems(ItemConfig)
    local totalItems = #ItemConfig

    for _, cfg in ipairs(ItemConfig) do

        -- Spawn the item mesh in the world
        local actor = StaticMesh(cfg.position, cfg.rotation, cfg.model, CollisionType.Normal)
        actor.Component:SetIsReplicated(true)

        -- Create interaction
        local interactor = Interactable({
            {
                Text = cfg.text,
                Input = "/Game/Helix/Input/Actions/IA_Interact.IA_Interact",

                -- Interaction logic
                Action = function(_, interactor)
                    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)

                    -- Ensure player belongs to current heist
                    if not (HeistManager.current and HeistManager.current.participants[src]) then
                        Notify(src, "You are not participating in this heist!", "#ff4444", 3000)
                        return
                    end

                    -- Mark item as collected
                    HeistManager.players.items[src] = HeistManager.players.items[src] or {}
                    HeistManager.players.items[src][cfg.item] = true

                    -- Remove item actor
                    actor:K2_DestroyActor()

                    -- Count collected items
                    local collected = 0
                    for _, itemCfg in ipairs(ItemConfig) do
                        if HeistManager.players.items[src][itemCfg.item] then
                            collected = collected + 1
                        end
                    end

                    -- All required items collected
                    if collected >= totalItems then
                        print("[Heist] Player completed item collection!")
                        OnAllItemsCollected(src)
                    end
                end
            }
        })

        -- Assign interaction to the prop
        interactor:SetInteractableProp(actor)

        -- Store reference
        HeistManager.props[cfg.id] = { actor = actor, config = cfg, interactor = interactor }
    end
end


-- Called when the player collected every required item
function OnAllItemsCollected(src)
    Notify(src, "Now go to the bank and start the Heist.", "#00ff88", 4000)
end



--========================================
-- SECTION: INTERACTIONS SYSTEM (SECURITY / MINIGAMES)
--========================================

function createHeistInteractions(securityConfig, heistId)
    for _, cfg in ipairs(securityConfig) do

        -- Spawn world object
        local actor = StaticMesh(cfg.position, cfg.rotation, cfg.model, CollisionType.Normal)
        actor.Component:SetIsReplicated(true)

        -- Create interactable action
        local interactor = Interactable({
            {
                Text = cfg.interactText,
                Input = "/Game/Helix/Input/Actions/IA_Interact.IA_Interact",

                Action = function()
                    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)

                    -- Only participants can interact
                    if not HeistManager.current.participants[src] then return end

                    -- Check required item (example: keycard, drill)
                    if cfg.requiredItem and not HeistManager.players.items[src][cfg.requiredItem] then return end

                    -- Trigger client minigame
                    TriggerClientEvent(src, "heist:client:startMinigame", {
                        minigame = cfg.minigame,
                        door = cfg.doorToOpen,
                        heistId = heistId
                    })
                end
            }
        })

        interactor:SetInteractableProp(actor)

        -- Save reference
        HeistManager.props[cfg.id] = { actor = actor, config = cfg, interactor = interactor }
    end
end



--========================================
-- SECTION: LOOT SYSTEM
--========================================

function createHeistLoots(lootsConfig)
    for _, cfg in ipairs(lootsConfig) do

        -- Spawn loot object
        local actor = StaticMesh(cfg.position, cfg.rotation, cfg.model, CollisionType.Normal)
        actor.Component:SetIsReplicated(true)

        local interactor = Interactable({
            {
                Text = cfg.text or "Pegar Loot",
                Input = "/Game/Helix/Input/Actions/IA_Interact.IA_Interact",

                Action = function()
                    local src = UE.UGameplayStatics.GetPlayerController(HWorld, 0)

                    -- Only participants can collect loot
                    if not HeistManager.current.participants[src] then return end

                    local currentWeight = HeistManager.players.weight[src] or 0
                    local newWeight = currentWeight + cfg.weight

                    -- Weight check (player can't carry infinite loot)
                    if newWeight > HeistManager.current.MaxWeight then
                        Notify(src, "You've already taken too much, get out of here, man, the police are coming!", "#ff4444", 4000)
                        return
                    end

                    -- Update weight and loot list
                    HeistManager.players.weight[src] = newWeight
                    HeistManager.players.loot[src] = HeistManager.players.loot[src] or {}

                    table.insert(HeistManager.players.loot[src], {
                        id = cfg.id,
                        value = cfg.value,
                        weight = cfg.weight
                    })

                    -- Remove loot actor
                    actor:K2_DestroyActor()
                end
            }
        })

        interactor:SetInteractableProp(actor)

        -- Register loot in heist props list
        HeistManager.props[cfg.id] = { actor = actor, config = cfg, interactor = interactor }
    end
end
