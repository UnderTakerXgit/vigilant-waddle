--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile()

ENT.Base = "pcams_cam_base"

ENT.PrintName = "Tactical Camera"
ENT.Spawnable = false
ENT.Category = "pCams"
ENT.Type = "anim"

ENT.Model = "models/freeman/owain_tactical_camera.mdl"
ENT.SWEP = "pcams_deploy_tacticalcamera"


function ENT:OffsetCamView(pos, ang)
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    return pos, ang
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
