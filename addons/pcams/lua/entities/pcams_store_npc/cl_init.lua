--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 200000 then return end

    local ang = LocalPlayer():EyeAngles()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

    surface.SetFont("pCams.NPC.Overhead")
    local textW, textH = surface.GetTextSize(PerfectCams.Translation.NPC.Overhead)

	cam.Start3D2D(self:GetPos() + (self:GetUp() * 80) + (self:GetForward() * 3), ang, 0.07)
        draw.RoundedBox(10, -(textW * 0.5) - 20, 0, textW+40, textH+10, PerfectCams.Colors.Black)

		draw.SimpleText(PerfectCams.Translation.NPC.Overhead, "pCams.NPC.Overhead", 0, 0, PerfectCams.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
