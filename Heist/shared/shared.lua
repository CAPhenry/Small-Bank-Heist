Config = {}

-- Global cooldown time between heists (in seconds)
Config.Cooldown = 30 * 60 -- 30 minutes

Config.Heists = {
    ["bank_heist_1"] = {

        -- Minimum number of players required to start the heist
        MinPlayers = 1,

        -- Chance (in %) for the alarm to automatically trigger
        AlarmChance = 50,

        -- Delay before police are notified after the heist starts
        PDDelay = 30,

        -- Extra delay after the vault is opened (increases police pressure)
        PDDelayAfterVaultOpen = 90,

        -- Starting area where players must stand to initiate the heist
        startPoint = {
            position = Vector(10723.087, -4238.877, -378.0), -- Start point location
            size = Vector(200), -- Detection zone size
            radius = 500, -- Detection zone size

            text = "Central Bank Heist", -- Text shown to the player
        },

        -- Maximum total loot weight the player can carry during the heist
        MaxWeight = 2000,

        -- Door configurations used throughout the heist
        DoorsConfig = {
            {
                id = "BankDoor1", -- Unique door ID
                role = "ENTRY_DOOR", -- Role in the heist flow
                position = Vector(-6640.0, 3980.0, -280.0), -- Door position
                rotation = Rotator(0, 0, 180), -- Door rotation
                mesh = "/Engine/BasicShapes/Cube.Cube", -- Door mesh
                initialScale = Vector(0.208, 5.0, 2.165), -- Initial scale
                openScaleY = 0.13, -- How much the Y scale changes when opening
                speed = 0.02, -- Opening animation speed
                interval = 10, -- Animation update interval
            },
            {
                id = "VaultDoor",
                role = "VAULT_DOOR", -- Vault door
                position = Vector(-7550.0, 3900.0, -250.0),
                rotation = Rotator(0, 0, 180),
                mesh = "/Engine/BasicShapes/Cube.Cube",
                initialScale = Vector(0.21, 5.024, 2.599),
                openScaleY = 0.051,
                speed = 0.02,
                interval = 10
            },
        },

        -- Required items that players must collect during the heist
        ItemsConfig = {
            {
                id = "RequiredItem_Phone", -- Internal item ID
                item = "phone", -- Inventory item name
                amount = 1, -- Required quantity
                model = "/Game/Items_HL/Assets/SM_Phone.SM_Phone", -- Object model
                position = Vector(-130.0, -3270.0, -370.0),
                rotation = Rotator(0, 0, 0),
                text = "Take Phone"
            },
            {
                id = "RequiredItem_Radio",
                item = "radio",
                amount = 1,
                model = "/Game/QBCore/Meshes/LP_Radio.LP_Radio",
                position = Vector(-120.0, -3290.0, -370.0),
                rotation = Rotator(0, 90.0, 0),
                text = "Take Radio"
            }
        },

        -- Security panels, hacking stations, and interactions
        SecurityConfig = {
            {
                id = "FuseBox_MainHall", -- Panel ID
                model = "/Game/Items_HL/Assets/SM_PowerBox3.SM_PowerBox3",
                position = Vector(-5880.0,3340.0,-280.0),
                rotation = Rotator(0, 0, 0),
                interactText = "Open Door", -- Interaction prompt
                doorToOpen = "BankDoor1", -- Door this panel unlocks
                minigame = "startTiming", -- Minigame to start
                requiredItem = "phone", -- Required item to interact
            },
            {
                id = "FuseBox_Vault",
                model = "/Game/Items_HL/Assets/SM_PowerBox3.SM_PowerBox3",
                position = Vector(-7520.0,3600.0,-280.0),
                rotation = Rotator(0, 0, 0),
                interactText = "Unlock Vault",
                doorToOpen = "VaultDoor",
                minigame = "startPattern",
                requiredItem = "radio",
            },
        },

        -- All lootable items located inside the vault
        LootsConfig = {

            -- Money stacks
            {
                id = "money_stack_01",
                model = "/Game/QBCore/Meshes/SM_MoneyStack.SM_MoneyStack",
                position = Vector(-8790.0, 4010.0, -300.0),
                rotation = Rotator(0, 0, 0),
                text = "Grab Money",
                value = 1000, -- Money value
                weight = 500, -- Inventory weight
            },
            {
                id = "money_stack_02",
                model = "/Game/QBCore/Meshes/SM_MoneyStack.SM_MoneyStack",
                position = Vector(-8790.0, 3950.0, -300.0),
                rotation = Rotator(0, 0, 0),
                text = "Grab Money",
                value = 1000,
                weight = 500,
            },
            {
                id = "money_stack_03",
                model = "/Game/QBCore/Meshes/SM_MoneyStack.SM_MoneyStack",
                position = Vector(-8790.0, 3890.0, -300.0),
                rotation = Rotator(0, 0, 0),
                text = "Grab Money",
                value = 1000,
                weight = 500,
            },
            {
                id = "money_stack_04",
                model = "/Game/QBCore/Meshes/SM_MoneyStack.SM_MoneyStack",
                position = Vector(-8790.0, 3810.0, -300.0),
                rotation = Rotator(0, 0, 0),
                text = "Grab Money",
                value = 1000,
                weight = 500,
            },
            {
                id = "money_stack_05",
                model = "/Game/QBCore/Meshes/SM_MoneyStack.SM_MoneyStack",
                position = Vector(-8790.0, 3740.0, -300.0),
                rotation = Rotator(0, 0, 0),
                text = "Grab Money",
                value = 1000,
                weight = 500,
            },

            -- High-value jewels
            {
                id = "Jewel_01",
                model = "/Game/QBCore/Meshes/LP_Jewel.LP_Jewel",
                position = Vector(-8790.0, 3620.0, -300.0),
                rotation = Rotator(0, -90.0, 0),
                value = 2000,
                weight = 500,
                text = "Grab Jewel"
            },
            {
                id = "Jewel_02",
                model = "/Game/QBCore/Meshes/LP_Jewel.LP_Jewel",
                position = Vector(-8790.0, 3540.0, -300.0),
                rotation = Rotator(0, -90.0, 0),
                value = 2000,
                weight = 500,
                text = "Grab Jewel"
            },
            {
                id = "Jewel_03",
                model = "/Game/QBCore/Meshes/LP_Jewel.LP_Jewel",
                position = Vector(-8790.0, 3460.0, -300.0),
                rotation = Rotator(0, -90.0, 0),
                value = 2000,
                weight = 500,
                text = "Grab Jewel"
            },
            {
                id = "Jewel_04",
                model = "/Game/QBCore/Meshes/LP_Jewel.LP_Jewel",
                position = Vector(-8790.0, 3390.0, -300.0),
                rotation = Rotator(0, -90.0, 0),
                value = 2000,
                weight = 500,
                text = "Grab Jewel"
            },
        },

        -- Area where the player must go AFTER escaping police to complete the heist
        LosePoliceAndFinishConfig = {
            position = Vector(-3910.0,12410.0,-310.0), -- Extraction point
            rotator = Rotator(0,0,0),
            size = Vector(200),
        },


    },
    --- here you can create more heist !
}