AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel('models/props_silo/silo_server_b.mdl')
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:CapabilitiesAdd( CAP_TURN_HEAD )
	self:DropToFloor()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	self.Platforms = {}
	self.Vehicles = {}
	self.Faction = TYPE_NONE
end

function ENT:Use(pPlayer)
	netstream.Start(pPlayer, 'NextRP::OpenSpawnerMenu', NextRP:GetAvaibleCars(pPlayer), self, self.Platforms, self.Vehicles, self.Faction, NextRPCarList)
end

function ENT:OnRemove()
	for k, v in pairs(self.Platforms) do v:Remove() end
end

function ENT:GetPlatforms()
	local t = {}

	for k, v in pairs(self.Platforms) do
		t[#t + 1] = {
			pos = v:GetPos(),
			ang = v:GetAngles()
		}
	end

	return t
end

function ENT:SpawnPlatforms(tData)
	for k, v in pairs(self.Platforms) do v:Remove() end
	self.Platforms = {}

	for k, v in pairs(tData) do
		local ePlatform = ents.Create('nextrp_carplatform')
		ePlatform:SetPos(v.pos)
		ePlatform:SetAngles(v.ang)

		ePlatform:SetNumber(#self.Platforms + 1)
		ePlatform:Spawn()

		self.Platforms[#self.Platforms + 1] = ePlatform
	end

	PrintTable(self.Platforms)
end

function ENT:OnTakeDamage()
    return 0
end

function ENT:Think()
    self:ResetSequence( self:LookupSequence( 'idle_all_01' ) )
    self:ResetSequenceInfo()
end

netstream.Hook('NextRP::SetFactionForDealer', function(pPlayer, eSpawner, nFaction)
	if not pPlayer:IsSuperAdmin() then return end

	eSpawner.Faction = nFaction
end)
netstream.Hook('NextRP::AddPlatform', function(pPlayer, eSpawner)
	if not pPlayer:IsSuperAdmin() then return end
	
	local ePlatform = ents.Create('nextrp_carplatform')
	ePlatform:SetPos(eSpawner:GetPos() + Vector(0, 0, 100))

	ePlatform:SetNumber(#eSpawner.Platforms + 1)
	ePlatform:Spawn()

	eSpawner.Platforms[#eSpawner.Platforms + 1] = ePlatform

	timer.Simple(.1, function()
		netstream.Start(pPlayer, 'NextRP::OpenSpawnerMenu', NextRP:GetAvaibleCars(pPlayer), eSpawner, eSpawner.Platforms, eSpawner.Vehicles, eSpawner.Faction, NextRPCarList)
	end)
end)
netstream.Hook('NextRP::RemovePlatform', function(pPlayer, eSpawner, iID)

	if not pPlayer:IsSuperAdmin() then return end
	if not IsValid(eSpawner.Platforms[iID]) then return end

	eSpawner.Platforms[iID]:Remove()
	eSpawner.Platforms[iID] = nil
	
	local counter = 0
	local platformsReplacment = {}

	for k, v in pairs(eSpawner.Platforms) do
		platformsReplacment[counter + 1] = v
		counter = counter + 1
	end

	eSpawner.Platforms = platformsReplacment

	timer.Simple(.1, function()
		netstream.Start(pPlayer, 'NextRP::OpenSpawnerMenu', NextRP:GetAvaibleCars(pPlayer), eSpawner, eSpawner.Platforms, eSpawner.Vehicles, eSpawner.Faction, NextRPCarList)
	end)
end)

netstream.Hook('NextRP::AddVehicle', function(pPlayer, eSpawner, sClass)
	if not pPlayer:IsSuperAdmin() then return end

	eSpawner.Vehicles[sClass] = true
	
	timer.Simple(.1, function()
		netstream.Start(pPlayer, 'NextRP::OpenSpawnerMenu', NextRP:GetAvaibleCars(pPlayer), eSpawner, eSpawner.Platforms, eSpawner.Vehicles, eSpawner.Faction, NextRPCarList)
	end)
end)

netstream.Hook('NextRP::RemoveVehicle', function(pPlayer, eSpawner, sClass)
	if not pPlayer:IsSuperAdmin() then return end

	eSpawner.Vehicles[sClass] = false
	
	timer.Simple(.1, function()
		netstream.Start(pPlayer, 'NextRP::OpenSpawnerMenu', NextRP:GetAvaibleCars(pPlayer), eSpawner, eSpawner.Platforms, eSpawner.Vehicles, eSpawner.Faction, NextRPCarList)
	end)
end)