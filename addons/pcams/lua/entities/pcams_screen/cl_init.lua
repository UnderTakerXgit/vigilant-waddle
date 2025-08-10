--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

include("shared.lua")

local offet = Vector(6.1, -28, 36)
local ang = Angle(0, 90, 90)
function ENT:Draw()
	if (!PerfectCams.Cache.TVs[self:EntIndex()]) then
		PerfectCams.Cache.TVs[self:EntIndex()] = self
	end
	self:DrawModel()

	cam.Start3D2D(self:LocalToWorld(offet), self:LocalToWorldAngles(ang), 0.1)
		draw.RoundedBox(0, 0, 0, 560, 335, color_black)

		local camera = self:GetCamera()

		if (!camera or !IsValid(camera)) then
			if (os.time()%2 == 0) then
				draw.SimpleText(PerfectCams.Translation.TV.NoSignal, "pCams.Screen.Text", 280, 165, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		else
			surface.SetMaterial(camera:GetRTMaterial())
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, 560, 335)
		end
	cam.End3D2D()
end

function ENT:OnRemove()
	PerfectCams.Cache.TVs[self:EntIndex()] = nil
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
