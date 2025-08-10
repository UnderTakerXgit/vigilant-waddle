AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
 
include('shared.lua')
 
local models = {
    'models/props_combine/breenglobe.mdl',
    'models/props_junk/metal_paintcan001a.mdl',
    'models/props_junk/MetalBucket01a.mdl',
}

local gifts = {
    {
        'Дополнительный слот',
        function(pPlayer) pPlayer:AddSlot(1) end,
        30
    },
    {
        '1000 рублей на донат счёт',
        function(pPlayer)
            pPlayer:AddIGSFunds(1000, 'Подарок на Новый год от команды сервера!')
        end,
        5
    },
    {
        '500 рублей на донат счёт',
        function(pPlayer)
            pPlayer:AddIGSFunds(500, 'Подарок на Новый год от команды сервера!')
        end,
        20
    },
    {
        '300 рублей на донат счёт',
        function(pPlayer)
            pPlayer:AddIGSFunds(300, 'Подарок на Новый год от команды сервера!')
        end,
        20
    },
    {
        '200 рублей на донат счёт',
        function(pPlayer)
            pPlayer:AddIGSFunds(200, 'Подарок на Новый год от команды сервера!')
        end,
        25
    },
}

local function generateGift()
    --Loop over items and create the chances
    local totalChance = 0
    for k ,v in pairs(gifts) do
        totalChance = totalChance + v[3]
    end

    local num = math.random(1 , totalChance)
    local prevCheck = 0
    local item = nil

    for k ,v in pairs(gifts) do
        if num >= prevCheck and num <= prevCheck + v[3] then
            item = k
        end
        prevCheck = prevCheck + v[3]
    end

    --return the result
    return gifts[item]
end

local text = Color(255, 255, 255)
local blue = Color(71, 141, 255)

function ENT:Initialize()
	self:SetModel( models[math.random(1, #models)] )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() 
	end

	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(pPlayer)
    if not pPlayer:IsPlayer() then return end

    if pPlayer:GetPData('newyear_2021', false) then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Ой! Не получилось достать ещё один подарок! У нас на каждого по одному подарку, не пытайтесь украсть чужой :)')
        return 
    end

    local gift = generateGift()
    gift[2](pPlayer)

    pPlayer:SetPData('newyear_2021', true)

    NextRP:SendGlobalMessage(blue, 'Новый год!', text, ' | ', pPlayer:FullName(), ' получил из новогоднего подарка ', blue, gift[1], text, '!')
end
