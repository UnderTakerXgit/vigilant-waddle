--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

AddCSLuaFile()

ENT.Base = "pcams_cam_base"

ENT.PrintName = "Thermal Camera"
ENT.Spawnable = false
ENT.Category = "pCams"
ENT.Type = "anim"

ENT.Model = "models/freeman/owain_wallhack_camera.mdl"
ENT.SWEP = "pcams_deploy_thermalcamera"


function ENT:ProcessPoseParams()
    // Gmod go brrrrrrrrrrrrrrrr
    self:SetPoseParameter("EOIR_cam_rotate", self:GetRotate())
    self:SetPoseParameter("EOIR_cam_pitch", self:GetPitch())
    self:InvalidateBoneCache()
end

function ENT:OffsetCamView(pos, ang)
    self:ProcessPoseParams()
    
    ang:RotateAroundAxis(ang:Right(), 90)
    //ang:RotateAroundAxis(ang:Forward(), 180)

    -- Rotate around controls
    local rotate = self:GetPoseParameter("EOIR_cam_rotate")
    local rangeMin, rangeMax = self:GetPoseParameterRange("EOIR_cam_rotate")
    rotate = math.Remap(rotate, 0, 1, rangeMin, rangeMax)
    ang:RotateAroundAxis(ang:Up(), rotate)

    local pitch = self:GetPoseParameter("EOIR_cam_pitch")
    local rangeMin, rangeMax = self:GetPoseParameterRange("EOIR_cam_pitch")
    pitch = math.Remap(pitch, 0, 1, rangeMin, rangeMax)
    ang:RotateAroundAxis(ang:Right(), -pitch)

    pos = pos + (ang:Up() * 5)
    pos = pos + (ang:Forward() * 5)

    return pos, ang
end

// We have network the pitch/rotate because setting 1 pose param server side resets the other one. Classic gmod.
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Pitch")
	self:NetworkVar("Int", 1, "Rotate")
    self:NetworkVar('Bool', 0, 'Thermal')
    self:NetworkVar("Entity", 0, "owning_ent")
end

// Thermal rendering
local background = Color(15, 13, 14, 254)
local foreground = Color(18, 101, 167, 254)
function ENT:PostRender()
    if (!self:GetThermal()) then return end

    cam.Start2D()
        surface.SetDrawColor(background)
        surface.DrawRect(0, 0, PerfectCams.Canvas.w, PerfectCams.Canvas.h)
    cam.End2D()

    render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)
		
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_ZERO)
        render.SuppressEngineLighting(true)
        render.OverrideDepthEnable(true, false)

            cam.Start3D()
                for _, ply in ipairs(player.GetAll()) do
                    if (!ply:Alive()) then continue end

                    ply:DrawModel()
                end
            cam.End3D()

        render.OverrideDepthEnable(false, false)
        render.SuppressEngineLighting(false)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)

            cam.Start2D()
                surface.SetDrawColor(foreground)
                surface.DrawRect(0, 0, PerfectCams.Canvas.w, PerfectCams.Canvas.h)
            cam.End2D()

        render.SetStencilEnable(false)
    render.ClearStencil()
end

// Controls
// We only expose these to the client to see if they are available, the functions are never actually ran.
function ENT:ActionLeft()
    local rangeMin, rangeMax = self:GetPoseParameterRange("EOIR_cam_rotate")

    local current = self:GetRotate()

    current = (current + 10)

    if current > rangeMax then
        current = rangeMin + (current - rangeMax)
    end

    self:SetRotate(current)
end
function ENT:ActionRight()
    local rangeMin, rangeMax = self:GetPoseParameterRange("EOIR_cam_rotate")

    local current = self:GetRotate()

    current = (current - 10)

    if current < rangeMin then
        current = rangeMax + current
    end

    self:SetRotate(current)
end
function ENT:ActionUp()
    local rangeMin, rangeMax = self:GetPoseParameterRange("EOIR_cam_pitch")

    local current = self:GetPitch()

    current = (current - 10)

    if current < rangeMin then
        current = rangeMin
    end

    self:SetPitch(current)
end
function ENT:ActionDown()
    local rangeMin, rangeMax = self:GetPoseParameterRange("EOIR_cam_pitch")

    local current = self:GetPitch()

    current = (current + 10)

    if current > rangeMax then
        current = rangeMax
    end

    self:SetPitch(current)
end
function ENT:ActionPrimary()
    self:SetThermal(!self:GetThermal())
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
