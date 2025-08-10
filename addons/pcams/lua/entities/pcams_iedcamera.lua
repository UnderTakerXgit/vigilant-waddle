--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile()

ENT.Base = "pcams_cam_base"

ENT.PrintName = "IED Camera"
ENT.Spawnable = false
ENT.Category = "pCams"
ENT.Type = "anim"

ENT.Model = "models/freeman/owain_bomb_camera.mdl"
ENT.SWEP = "pcams_deploy_iedcamera"

function ENT:OffsetCamView(pos, ang)
    ang:RotateAroundAxis(ang:Forward(), 180)

    return pos, ang
end

function ENT:ActionPrimary()
    local effectdata = EffectData()
	effectdata:SetStart(self:GetPos())
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)

    util.BlastDamage(self, self, self:GetPos(), PerfectCams.Config.Cameras.IED.Range, PerfectCams.Config.Cameras.IED.Damage)

    self:Remove()
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
