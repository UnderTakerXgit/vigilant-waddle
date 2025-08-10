--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Sets the npcs model and basic physics ect..
function ENT:Initialize()
	self:SetModel(PerfectCams.Config.Store.Model)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:SetPos(self:GetPos()+Vector(0,0,10))
    self:DropToFloor()
	self:SetTrigger(true)

	self:ResetSequence(self:LookupSequence("lineidle02"))
    self:ResetSequenceInfo()
end

function ENT:OnTakeDamage()
	return 0    
end


function ENT:AcceptInput(name, activator, caller)
    if PerfectCams.Cooldown.Check("Store:AcceptInput", 3, activator) then return end
	
	-- Basic checks
	if activator:IsPlayer() == false then return end
	if activator:GetPos():Distance( self:GetPos() ) > 100 then return end

	net.Start("pCams:Store:UI")
		net.WriteEntity(self)
	net.Send(activator)
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
