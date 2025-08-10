--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

local APP = {} -- First we build the app object. Keep in mind that the APP object is never "reset".
-- So if you store things in it, those vars will be there forever. If you want a place to temp store stuff
-- that will be deleted each time the app is loaded, you can use a table within the APP object called
-- "garbage". "garbage" will be reset as soon as the app is opened
APP.garbage = {}

APP.UniqueName = "share" -- This is a unique name with no special characters or uppercase (Excluding _)
APP.Name = "Share" -- Give the app a display name
APP.ShowOnHUB = true -- Should the app show on the HUB?

-- This is called when the app is opened
function APP:Load()
	self.garbage.scroll = PerfectCams.UI.New3DScroll()
		:SetItemHeight(70)
		:SetItemPadding(20)

	self.garbage.buttons = {}

	self.garbage.avatars = {}
end

-- This is called when the app is closed.
-- Note: It is not called on events like SWEP change or unexpected turn off. Only when the app is exited back into the HUB
function APP:Close()

end

-- Paint the thumbnail to be shown on the HUB (Not needed if not shown on HUB)
local color_green = Color(38, 153, 39)
function APP:PaintThumbnail(x, y, w, h)
	draw.NoTexture()
	surface.SetDrawColor(color_green)
	surface.SetMaterial(PerfectCams.Core.GetImage('square_rounded'))
	surface.DrawTexturedRect(x, y, w, h)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(PerfectCams.Core.GetImage('social'))
	surface.DrawTexturedRect(x + 20, y + 20, w - 40, h - 40)
end

-- This is the function that is called while the app is open, and is shown "full screen". You should do all your
-- interface and logic here. This is basically the heart of the app.
local padding = 20
function APP:Render(x, y, w, h)
	if (!self.garbage) then return end
	if (!self.garbage.scroll) then return end
	if (!self.garbage.avatars) then return end
	if (!self.garbage.buttons) then return end

	local x, y, w, h = x + padding, y + padding, w - (padding * 2), h - (padding * 2)

	draw.SimpleText(PerfectCams.Translation.Screen.Share, "pCams.Screen.Title", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(PerfectCams.Translation.Screen.ShareDesc, "pCams.Screen.SubTitle", x, y + 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	self.garbage.scroll:SetPos(x, y + 90)
		:SetSize(w, h - 90)
	self.garbage.scroll.items = {}

	for k, ply in ipairs(player.GetAll()) do
		if (not IsValid(ply)) then continue end
		if (ply == LocalPlayer()) then continue end

		local steamId = ply:SteamID()

		if (!self.garbage.avatars[steamId]) then
			self.garbage.avatars[steamId] = vgui.Create("pCams.RoundAvatar")
			self.garbage.avatars[steamId]:SetPlayer(ply, 64)
			self.garbage.avatars[steamId]:SetPaintedManually(true)
		end

		if (!self.garbage.buttons['player_' .. steamId]) then
			self.garbage.buttons['player_' .. steamId] = PerfectCams.UI.New3DButton()
				:DoClick(function()
					PerfectCams.Share[steamId] = !PerfectCams.Share[steamId]

					net.Start("pCams:Phone:Share")
						net.WriteString(ply:SteamID64())
						net.WriteBool(PerfectCams.Share[steamId])
					net.SendToServer()
				end)
			
			self.garbage.buttons['player_' .. steamId].paint = function(_, x, y, w, h)
				draw.RoundedBox(10, x, y, w, h, PerfectCams.Colors.GrayLight)
	
				if (self.garbage.avatars[steamId]) then
					self.garbage.avatars[steamId]:SetSize(50, 50)
					self.garbage.avatars[steamId]:SetPos(x + 10, y + 10)
					self.garbage.avatars[steamId]:PaintManual()
				end
	
				draw.SimpleText(ply:Name(), "pCams.Screen.Text", x + 70, y + 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
				draw.RoundedBox(10, x + w - 210, y + 10, 200, 50, PerfectCams.Share[steamId] and PerfectCams.Colors.Green or PerfectCams.Colors.Red)
				draw.SimpleText(PerfectCams.Share[steamId] and PerfectCams.Translation.Screen.Allowed or PerfectCams.Translation.Screen.Disallowed, "pCams.Screen.Text", x + w - 110, y + 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
			end
		end
	
		self.garbage.scroll:AddItem(self.garbage.buttons['player_' .. steamId])
	end

	self.garbage.scroll:Paint()

end


return APP -- Returning the APP will have pCams auto register it.

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
