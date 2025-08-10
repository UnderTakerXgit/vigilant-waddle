--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	phys:Wake()

	if (self.CPPISetOwner) then
		self:CPPISetOwner(self:Getowning_ent())
	end

	self.health = PerfectCams.Config.Cameras.Health[self:GetClass()]
end

function ENT:Use(ply)
	if (!ply || !ply:IsPlayer()) then return end

	local cameraData = PerfectCams.Cameras[self:EntIndex()]

	if (!cameraData) then return end

	if (cameraData.owner != ply) then return end

	local swep = ply:GetWeapon(self.SWEP)

	if (!swep || !IsValid(swep)) then
		ply:Give(self.SWEP)
	else
		swep.PlaceCount = swep.PlaceCount + 1
		swep:SetClip2(swep.PlaceCount)
	end

	self:Remove()
end

function ENT:OnTakeDamage(dmg)
	if (self.IsPerma) then return end
	if (!isnumber(self.health)) then return end

	local damage = dmg:GetDamage() or 0

	self.health = self.health - damage

	if (self.health <= 0) then
		local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(0.5)
		util.Effect('Explosion', effectdata)

		self:Remove()
	end
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
