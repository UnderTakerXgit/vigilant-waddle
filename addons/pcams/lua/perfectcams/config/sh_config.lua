--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

/* ============
 General Config
=============*/

-- Chat prefix
PerfectCams.Config.PrefixColor = Color(175, 0, 0)
PerfectCams.Config.Prefix = "[Наблюдение] "

-- Max placement distance from player
PerfectCams.Config.MaxDeployDistance = 20000
-- The max amount of cameras a player can have placed at one time
PerfectCams.Config.MaxCameras = 3
-- Enabling this will ensure that if a player has access to a placed camera in any way, they will be given a surveillance monitor
PerfectCams.Config.AutoSurveillance = true

/* =======
App Config
========*/
PerfectCams.Config.LinkT = {}
-- The max distance you can be to cast a camera to a TV
PerfectCams.Config.LinkT.ShareDistance = 40000


/* ==========
Camera Config
===========*/
PerfectCams.Config.Cameras = {}
PerfectCams.Config.Cameras.IED = {}

-- How much damage does the IED do?
PerfectCams.Config.Cameras.IED.Damage = 400
-- The range of the IED explosion
PerfectCams.Config.Cameras.IED.Range = 300

-- Optionally, you can set the FPS of the cameras. This can be useful for performance in some cases.
-- It is disabled by default, but you can set it to a number to limit the FPS of the cameras.
-- PerfectCams.Config.Cameras.FPS = 30 // 30 FPS example
PerfectCams.Config.Cameras.FPS = false

-- Each camera and its health
-- This should either be a number or the value <false>.
-- If false is provided, the camera will be invincible.
PerfectCams.Config.Cameras.Health = {
    ['pcams_iedcamera'] = 100,
    ['pcams_microcamera'] = 100,
    ['pcams_motioncamera'] = 100,
    ['pcams_ptcamera'] = 100,
    ['pcams_tacticalcamera'] = false, -- Make this one invincible as an example
    ['pcams_thermalcamera'] = 100
}


/* ======================
 Permanent Cameras Config
=======================*/

PerfectCams.Config.PermaCameras = PerfectCams.Config.PermaCameras or {}
PerfectCams.Config.PermaCameras.Groups = {
    ['police'] = {
        name = "Admin",
        canAccess = function(pPlayer)
            return pPlayer:IsAdmin()
        end
    },
    ['uss'] = {
        name = "USS",
        canAccess = function(pPlayer)
            return true
        end
    },
}



/* ==========
 Store Config
===========*/
-- If you would prefer, you can use a different NPC Store system and include these SWEPs as purchasable items.
PerfectCams.Config.Store = {}

-- NPC Store Model
PerfectCams.Config.Store.Model = "models/Barney.mdl"

-- The items for this store.
PerfectCams.Config.Store.Items = {
    {
        name = "Surveillance Monitor", -- The display name inside of the store
        class = "pcams_mobile", -- The SWEP class
        price = 1000 -- The cost of this item
    },
    {
        name = "Tactical Camera", -- The display name inside of the store
        class = "pcams_deploy_tacticalcamera", -- The SWEP class
        price = 1000 -- The cost of this item
    },
    {
        name = "Micro Camera", -- The display name inside of the store
        class = "pcams_deploy_microcamera", -- The SWEP class
        price = 1000 -- The cost of this item
    },
    {
        name = "PT Camera", -- The display name inside of the store
        class = "pcams_deploy_ptcamera", -- The SWEP class
        price = 1000 -- The cost of this item
    },
    {
        name = "Motion Camera", -- The display name inside of the store
        class = "pcams_deploy_motioncamera", -- The SWEP class
        price = 1000 -- The cost of this item
    },
    {
        name = "IED Camera", -- The display name inside of the store
        class = "pcams_deploy_iedcamera", -- The SWEP class
        price = 1000 -- The cost of this item
    },
    {
        name = "Thermal Camera", -- The display name inside of the store
        class = "pcams_deploy_thermalcamera", -- The SWEP class
        price = 1000, -- The cost of this item
        canPurchase = function(ply) -- You can use this to check if a player can purchase this item
            return table.HasValue({"superadmin", "admin", 'vip+', 'vip'}, ply:GetUserGroup())
        end
    },
    /*
    -- It is suggested to sell this with something like the F4 menu insted 
    {
        name = "TV", -- The display name inside of the store
        class = "pcams_screen", -- The SWEP class
        price = 1000, -- The cost of this item
        entity = true -- If this is an entity that is spawned into the world
    }
    */
}

-- How to format the money. You only need to change this if you aren't using DarkRP
function PerfectCams.Config.Store.Format(amount)
    return DarkRP.formatMoney(amount)
end
-- Can the player afford this purchase? You only need to change this if you aren't using DarkRP
function PerfectCams.Config.Store.CanAfford(ply, amount)
    return ply:canAfford(amount)
end
-- Take the money from a player. You only need to change this if you aren't using DarkRP
function PerfectCams.Config.Store.TakeMoney(ply, amount)
    return ply:addMoney(-amount)
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
