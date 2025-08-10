--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

SWEP.PrintName = "КПК"
SWEP.Author = "Rephyx.tech"
SWEP.Category = "КПК"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.ViewModel = Model("models/freeman/c_owain_fieldmonitor.mdl")
SWEP.WorldModel = "models/freeman/owain_fieldmonitor.mdl"
SWEP.ViewModelFOV = 50
SWEP.UseHands = true
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"

SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "camera"

-- States
SWEP.OnState = false
SWEP.MouseToggle = false
SWEP.CurrentApp = nil -- This is the "starting" app, it does the loading thingy

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)

	if CLIENT then
		self:ChangeApp("load")

		local viewmodel = self:GetOwner():GetViewModel()
		if (!IsValid(viewmodel)) then return end
		viewmodel:SendViewModelMatchingSequence(viewmodel:LookupSequence("idle_down"))
	end
end

function SWEP:PrimaryAttack()
	if PerfectCams.Cooldown.Check("Mobile:PrimaryAttack", 3, self:GetOwner()) then return end

	self.OnState = not self.OnState
	
	local viewmodel = self:GetOwner():GetViewModel()
	if (!IsValid(viewmodel)) then return end

	viewmodel:SendViewModelMatchingSequence(viewmodel:LookupSequence(self.OnState and "bringup" or "takedown"))

	-- Wait for the animation to run
	timer.Simple(1, function()
		if (!IsValid(viewmodel)) then return end
		viewmodel:SendViewModelMatchingSequence(viewmodel:LookupSequence(self.OnState and "idle_up" or "idle_down"))

		if self.OnState and !self.PostInitialLoad then
			self:SecondaryAttack() -- Turn it on
			self.PostInitialLoad = true
		end
	end)
end
function SWEP:SecondaryAttack()
	if SERVER then return end

	if PerfectCams.Cooldown.Check("Mobile:SecondaryAttack", 1) then return end
	self:ChangeApp("load")
end
function SWEP:Reload()
	if SERVER then return end
	if (!self.OnState and !self.MouseToggle) then return end

	if PerfectCams.Cooldown.Check("Mobile:Reload", 1) then return end
	self.MouseToggle = not self.MouseToggle
	gui.EnableScreenClicker(self.MouseToggle)
end

function SWEP:Deploy()
	local viewmodel = self:GetOwner():GetViewModel()
	if (!IsValid(viewmodel)) then return end
	viewmodel:SendViewModelMatchingSequence(viewmodel:LookupSequence(self.OnState and "idle_up" or "idle_down"))
end

if SERVER then return end

function SWEP:ChangeApp(app, passthrough)
	local getApp = PerfectCams.Apps.Get(app)
	if not getApp then return false end -- Not a valid app

	getApp.garbage = {} -- Reset the garbage
	getApp.garbage.passthrough = passthrough

	self.CurrentApp = getApp
end

function SWEP:GetApp()
	return self.CurrentApp
end


local screenW, screenH = PerfectCams.Canvas.w, 886
local transBackground = Color(0, 0, 0, 200)
function SWEP:PostDrawViewModel(entity, weapon, ply)
	if not (entity:GetSequence() == 1) then return end -- The phone is not in-front of us, we consider the phone "off"

	local pos, ang = entity:GetBonePosition(30)
	if not pos then return end
	if not ang then return end
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Forward(), -1)

	pos = pos - (entity:GetForward() * -9.95) - (entity:GetRight() * 3.36) + (entity:GetUp() * 2.17)
	
	if PerfectCams.Libs.Imgui.Weapon3D2D(self, pos, ang, 0.0045) then
		render.ClearStencil()
		render.SetStencilEnable(true)
	
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
	
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)
	
			draw.NoTexture()
			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(0, 0, PerfectCams.Canvas.w, PerfectCams.Canvas.h)
	
		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1)

			PerfectCams.Render.DrawScreen(self, PerfectCams.Canvas.w, PerfectCams.Canvas.h)

			if (!vgui.CursorVisible()) then
				draw.RoundedBox(0, 0, 0, PerfectCams.Canvas.w, PerfectCams.Canvas.h, transBackground)
				draw.SimpleText(PerfectCams.Translation.Screen.ToggleCursor, "pCams.Screen.Title", screenW * 0.5, screenH * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
	
		render.SetStencilEnable(false)
		render.ClearStencil()

		PerfectCams.Libs.Imgui.End3D2D()
	end
end


local posOffset, angOffset = Vector(4.3, -5, -1), Angle(180, 0, -10)
function SWEP:DrawWorldModel()
	if (!self.worldModel) then
		self.worldModel = ClientsideModel(self.WorldModel)
		self.worldModel:SetNoDraw(true)
	end

	local owner = self:GetOwner()
	if (IsValid(owner)) then
		local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if !boneid then return end

		local matrix = owner:GetBoneMatrix(boneid)
		if !matrix then return end

		local newPos, newAng = LocalToWorld(posOffset, angOffset, matrix:GetTranslation(), matrix:GetAngles())
		
		self.worldModel:SetPos(newPos)
		self.worldModel:SetAngles(newAng)
        self.worldModel:SetupBones()
	else
		self.worldModel:SetPos(self:GetPos())
		self.worldModel:SetAngles(self:GetAngles())
	end
    
	self.worldModel:DrawModel()
end

function SWEP:Holster()
	if IsValid(self.worldModel) then
		self.worldModel:Remove()
		self.worldModel = nil
	end
	gui.EnableScreenClicker(false)
end

function SWEP:OnRemove()
    self:Holster()
end

concommand.Add("pcams_check_access", function()
    local ply = LocalPlayer()

    if not IsValid(ply) then
        print("[pCams] ❌ Игрок не валиден.")
        return
    end

    local groups = PerfectCams.Config.PermaCameras.Groups
    if not groups then
        print("[pCams] ⚠️ Группы не загружены.")
        return
    end

    for id, data in pairs(groups) do
        local canAccess = false

        if data.canAccess then
            local success, result = pcall(data.canAccess, ply)
            if success then
                canAccess = result
            else
                print("[pCams] ⚠️ Ошибка в canAccess для группы " .. id .. ": " .. tostring(result))
            end
        end

        print(Format("[pCams] Группа: %s | Название: %s | Доступ: %s", id, data.name or "Без имени", canAccess and "✅" or "❌"))
    end
end)

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
