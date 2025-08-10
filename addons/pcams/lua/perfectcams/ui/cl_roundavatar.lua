--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

-- Stolen from Livaco
local PANEL = {}

function PANEL:Init()
	self.avatar = vgui.Create("AvatarImage", self)
	self.avatar:SetPaintedManually(true)
end

function PANEL:PerformLayout()
	self.avatar:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:SetPlayer(ply, size)
	self.avatar:SetPlayer(ply, size)
end
function PANEL:SetSteamID(sid, size)
	self.avatar:SetSteamID(sid, size)
end


local ball = Material("sprites/sent_ball", "smooth nocull noclamp")

function PANEL:Paint(w, h)
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
        surface.SetMaterial(ball)
        surface.DrawTexturedRect(0, 0, w, h)

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(1)

		self.avatar:PaintManual()

    render.SetStencilEnable(false)
    render.ClearStencil()
end

vgui.Register("pCams.RoundAvatar", PANEL)

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
