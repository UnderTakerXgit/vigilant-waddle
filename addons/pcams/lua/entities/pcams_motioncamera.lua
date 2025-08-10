--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile()

ENT.Base = "pcams_cam_base"

ENT.PrintName = "Motion Camera"
ENT.Spawnable = false
ENT.Category = "pCams"
ENT.Type = "anim"

ENT.Model = "models/freeman/owain_lasercam.mdl"
ENT.SWEP = "pcams_deploy_motioncamera"


function ENT:OffsetCamView(pos, ang)
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    return pos, ang
end

function ENT:TriggerLine()
    local pos = self:GetPos() + (self:GetUp() * -1.43) + (self:GetRight() * 0.22)
    local endPos = pos + (self:GetForward() * 120)

    return pos, endPos
end


if SERVER then
    sound.Add({name = "pcams_motion_alarm", channel = CHAN_STATIC, volume = 0.3, level = 80, pitch = {95, 110}, sound = Sound("npc/attack_helicopter/aheli_damaged_alarm1.wav")}) 
    function ENT:TriggerAlarm()
        local cameraData = PerfectCams.Cameras[self:EntIndex()]
    
        if (!cameraData) then return end
        if (!IsValid(cameraData.owner)) then return end

        if (PerfectCams.Cooldown.Check('pcams_motion_alarm_' .. self:EntIndex(), 1)) then return end

        cameraData.owner:EmitSound("pcams_motion_alarm")
    end

    function ENT:Think()
        local posStart, posEnd = self:TriggerLine()

        local tr = util.TraceLine({
            start = posStart,
            endpos = posEnd,
            filter = self
        })

        if (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
            self:TriggerAlarm()
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local posStart, posEnd = self:TriggerLine()

        render.DrawLine(posStart, posEnd, PerfectCams.Colors.Red, true)
    end
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
