--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Screen"
ENT.Author = "Owain Owjo"
ENT.Category = "pCams"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Model = "models/props/cs_office/tv_plasma.mdl"

ENT.IsPCamsTV = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Camera")
	self:NetworkVar("Entity", 1, "owning_ent")
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
