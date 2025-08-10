--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Base Camera"
ENT.Author = "Owain Owjo"
ENT.Category = "pCams"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/freeman/owain_microcam.mdl"

ENT.SWEP = "pcams_deploy_base"

ENT.IsPCamsCamera = true

-- Use this function to edit the pos and ang for specific cams
function ENT:OffsetCamView(pos, ang)
	return pos, ang
end

function ENT:GetCamView()
	-- Rotate the view
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetRight(), 90)
	ang:RotateAroundAxis(self:GetUp(), 180)

	return self:OffsetCamView(self:GetPos(), ang)
end

function ENT:OnRemove()
	-- Remove the camera from the table
	PerfectCams.Cameras[self:EntIndex()] = nil
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
