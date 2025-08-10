--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile()

ENT.Base = "pcams_cam_base"

ENT.PrintName = "PT Camera"
ENT.Spawnable = false
ENT.Category = "pCams"
ENT.Type = "anim"

ENT.Model = "models/freeman/owain_spherecam.mdl"
ENT.SWEP = "pcams_deploy_ptcamera"

function ENT:ProcessPoseParams()
    // Gmod go brrrrrrrrrrrrrrrr
    self:SetPoseParameter("camera_rotate", self:GetRotate())
    self:SetPoseParameter("camera_pitch", self:GetPitch())
    self:InvalidateBoneCache()
end

function ENT:OffsetCamView(pos, ang)
    self:ProcessPoseParams()

    ang:RotateAroundAxis(ang:Forward(), 180)

    -- Rotate around controls
    local rotate = self:GetPoseParameter("camera_rotate")
    local rangeMin, rangeMax = self:GetPoseParameterRange("camera_rotate")
    rotate = math.Remap(rotate, 0, 1, rangeMin, rangeMax)
    ang:RotateAroundAxis(ang:Forward(), rotate)

    local pitch = self:GetPoseParameter("camera_pitch")
    local rangeMin, rangeMax = self:GetPoseParameterRange("camera_pitch")
    pitch = math.Remap(pitch, 0, 1, rangeMin, rangeMax)
    ang:RotateAroundAxis(ang:Right(), -pitch)

    pos = pos + (ang:Up() * 2)
    pos = pos + (ang:Forward() * 2)
    
    ang:RotateAroundAxis(ang:Forward(), -180)


    return pos, ang
end

// We have network the pitch/rotate because setting 1 pose param server side resets the other one. Classic gmod.
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Pitch")
	self:NetworkVar("Int", 1, "Rotate")
    self:NetworkVar("Entity", 0, "owning_ent")
end

function ENT:ActionLeft()
    local rangeMin, rangeMax = self:GetPoseParameterRange("camera_rotate")

    local current = self:GetRotate()

    current = (current - 10)

    if current < rangeMin then
        current = rangeMax + current
    end

    self:SetRotate(current)
end
function ENT:ActionRight()
    local rangeMin, rangeMax = self:GetPoseParameterRange("camera_rotate")

    local current = self:GetRotate()

    current = (current + 10)

    if current > rangeMax then
        current = rangeMin + (current - rangeMax)
    end

    self:SetRotate(current)
end
function ENT:ActionUp()
    local rangeMin, rangeMax = self:GetPoseParameterRange("camera_pitch")

    local current = self:GetPitch()

    current = (current + 10)

    if current > rangeMax then
        current = rangeMax
    end

    self:SetPitch(current)
end
function ENT:ActionDown()
    local rangeMin, rangeMax = self:GetPoseParameterRange("camera_pitch")

    local current = self:GetPitch()

    current = (current - 10)

    if current < rangeMin then
        current = rangeMin
    end

    self:SetPitch(current)
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
