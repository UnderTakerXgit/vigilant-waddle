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

APP.UniqueName = "view3r" -- This is a unique name with no special characters or uppercase (Excluding _)
APP.Name = "View3r" -- Give the app a display name
APP.ShowOnHUB = true -- Should the app show on the HUB?

-- Color cache
local darkGrey = Color(30, 30, 30)
-- This is called when the app is opened
function APP:Load(ent, w, h)
	self:NextCamera()

	self.garbage.sharePopup = false
	self.garbage.buttons = {}

	if (self.garbage.passthrough) then
		local camera = PerfectCams.Cameras[self.garbage.passthrough]
		if (camera) then
			self.garbage.camera = camera
		end
	end

	self.garbage.LinkTScroll = PerfectCams.UI.New3DScroll()
		:SetItemHeight(70)
		:SetItemPadding(20)
end

-- This is called when the app is closed.
-- Note: It is not called on events like SWEP change or unexpected turn off. Only when the app is exited back into the HUB
function APP:Close()
	PerfectCams.ActiveCamera = nil
end

-- Paint the thumbnail to be shown on the HUB (Not needed if not shown on HUB)
local color_blue = Color(23, 140, 175)
function APP:PaintThumbnail(x, y, w, h)
	draw.NoTexture()
	surface.SetDrawColor(color_white)
	surface.SetMaterial(PerfectCams.Core.GetImage('square_rounded'))
	surface.DrawTexturedRect(x, y, w, h)

	surface.SetDrawColor(color_blue)
	surface.SetMaterial(PerfectCams.Core.GetImage('eye'))
	surface.DrawTexturedRect(x + 20, y + 20, w - 40, h - 40)
end

-- This is the function that is called while the app is open, and is shown "full screen". You should do all your
-- interface and logic here. This is basically the heart of the app.
local localPly
local padding = 20
local paginationHeight = 60
local transBackground = Color(0, 0, 0, 220)
function APP:Render(x, y, w, h)
	if (!self.garbage) then return end
	if (!self.garbage.LinkTScroll) then return end
	if (!self.garbage.buttons) then return end

	local x, y, w, h = x + padding, y + padding, w - (padding * 2), h - (padding * 2)
	local cameraX, cameraY, cameraW, cameraH = x, y, w, h - paginationHeight

	if (!localPly) then
		localPly = LocalPlayer()
	end

	if self.garbage.camera and self.garbage.camera.entIndex then
		local ent = ents.GetByIndex(self.garbage.camera.entIndex)

		if (PerfectCams.Cameras[self.garbage.camera.entIndex] and IsValid(ent)) then

			local aspect = ent:GetRTMaterial():Width() / ent:GetRTMaterial():Height()

			-- Draw active camera
			PerfectCams.UI.RoundedImage(40, cameraX, cameraY, cameraW, cameraH)
				surface.SetMaterial(ent:GetRTMaterial())
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRectRotated(cameraX + (cameraW * 0.5), cameraY + (cameraH * 0.5), (aspect * cameraH) * 1.1, cameraH, 0)
			PerfectCams.UI.RoundedImageEnd()

			
			surface.SetFont("pCams.Screen.Text")
			local width, height = surface.GetTextSize(PerfectCams.Cameras[self.garbage.camera.entIndex].name or PerfectCams.Translation.Screen.Name)
			if (!self.garbage.buttons['name']) then
				self.garbage.buttons['name'] = PerfectCams.UI.New3DButton()
					:SetPos(x, y + h - 50)
					:SetSize(width + 20, 50)
					:DoClick(function()
						PerfectCams.Core.PromptInput(PerfectCams.Translation.Screen.NameCamera, PerfectCams.Translation.Screen.NameCameraDesc, function(name)
							net.Start('pCams:Camera:Name')
								net.WriteUInt(ent:EntIndex(), 16)
								net.WriteString(name)
							net.SendToServer()
						end)
					end)

				self.garbage.buttons['name'].paint = function(_, x, y, w, h)
					draw.RoundedBox(10, x, y, w, h, PerfectCams.Colors.Gray)
					draw.SimpleText(PerfectCams.Cameras[self.garbage.camera.entIndex].name or PerfectCams.Translation.Screen.Name, "pCams.Screen.Text", x + 10, y + h - 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end

			self.garbage.buttons['name']:SetSize(width + 20, 50)
			self.garbage.buttons['name']:Paint(self.garbage.buttons['name'].paint)


			-- Action buttons
			if (ent.ActionLeft) then
				if (!self.garbage.buttons['action_left']) then
					self.garbage.buttons['action_left'] = PerfectCams.UI.New3DButton()
						:SetPos(cameraX + cameraW - 180, cameraY + cameraH - 120)
						:SetSize(50, 50)

					self.garbage.buttons['action_left'].paint = function(self, x, y, w, h)
						surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
						surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
						surface.DrawTexturedRect(x, y, w, h)

						surface.SetDrawColor(color_white)
						surface.SetMaterial(PerfectCams.Core.GetImage("arrow_rotate_left"))
						surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
					end
				end

				self.garbage.buttons['action_left']:DoClick(function()
					net.Start('pCams:Camera:Action')
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteUInt(PerfectCams.ENUM.LEFT, 4)
					net.SendToServer()
				end)
				self.garbage.buttons['action_left']:Paint(self.garbage.buttons['action_left'].paint)
			end
			if (ent.ActionRight) then
				if (!self.garbage.buttons['action_right']) then
					self.garbage.buttons['action_right'] = PerfectCams.UI.New3DButton()
						:SetPos(cameraX + cameraW - 60, cameraY + cameraH - 120)
						:SetSize(50, 50)

					self.garbage.buttons['action_right'].paint = function(self, x, y, w, h)
						surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
						surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
						surface.DrawTexturedRect(x, y, w, h)

						surface.SetDrawColor(color_white)
						surface.SetMaterial(PerfectCams.Core.GetImage("arrow_rotate_right"))
						surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
					end
				end

				self.garbage.buttons['action_right']:DoClick(function()
					net.Start('pCams:Camera:Action')
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteUInt(PerfectCams.ENUM.RIGHT, 4)
					net.SendToServer()
				end)
				self.garbage.buttons['action_right']:Paint(self.garbage.buttons['action_right'].paint)
			end

			if (ent.ActionUp) then
				if (!self.garbage.buttons['action_up']) then
					self.garbage.buttons['action_up'] = PerfectCams.UI.New3DButton()
						:SetPos(cameraX + cameraW - 120, cameraY + cameraH - 180)
						:SetSize(50, 50)

					self.garbage.buttons['action_up'].paint = function(self, x, y, w, h)
						surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
						surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
						surface.DrawTexturedRect(x, y, w, h)
	
						surface.SetDrawColor(color_white)
						surface.SetMaterial(PerfectCams.Core.GetImage("arrow_rotate_up"))
						surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
					end
				end

				self.garbage.buttons['action_up']:DoClick(function()
					net.Start('pCams:Camera:Action')
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteUInt(PerfectCams.ENUM.UP, 4)
					net.SendToServer()
				end)
				self.garbage.buttons['action_up']:Paint(self.garbage.buttons['action_up'].paint)
			end
			if (ent.ActionDown) then
				if (!self.garbage.buttons['action_down']) then
					self.garbage.buttons['action_down'] = PerfectCams.UI.New3DButton()
						:SetPos(cameraX + cameraW - 120, cameraY + cameraH - 60)
						:SetSize(50, 50)
						
					self.garbage.buttons['action_down'].paint = function(self, x, y, w, h)
						surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
						surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
						surface.DrawTexturedRect(x, y, w, h)

						surface.SetDrawColor(color_white)
						surface.SetMaterial(PerfectCams.Core.GetImage("arrow_rotate_down"))
						surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
					end
				end

				self.garbage.buttons['action_down']:DoClick(function()
					net.Start('pCams:Camera:Action')
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteUInt(PerfectCams.ENUM.DOWN, 4)
					net.SendToServer()
				end)
				self.garbage.buttons['action_down']:Paint(self.garbage.buttons['action_down'].paint)
			end
			if (ent.ActionPrimary) then
				if (!self.garbage.buttons['action_primary']) then
					self.garbage.buttons['action_primary'] = PerfectCams.UI.New3DButton()
						:SetPos(cameraX + cameraW - 120, cameraY + cameraH - 120)
						:SetSize(50, 50)
						
					self.garbage.buttons['action_primary'].paint = function(self, x, y, w, h)
						surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
						surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
						surface.DrawTexturedRect(x, y, w, h)
	
						surface.SetDrawColor(color_white)
						surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
						surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
					end
				end

				self.garbage.buttons['action_primary']:DoClick(function()
					net.Start('pCams:Camera:Action')
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteUInt(PerfectCams.ENUM.PRIMARY, 4)
					net.SendToServer()
				end)
				self.garbage.buttons['action_primary']:Paint(self.garbage.buttons['action_primary'].paint)
			end


			draw.RoundedBox(10, cameraX + cameraW - padding - 105, cameraY + padding, 105, 50, PerfectCams.Colors.Gray)
			draw.SimpleText(PerfectCams.Translation.Screen.Live, "pCams.Screen.Text", cameraX + cameraW - padding - 10, cameraY + padding + 25, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			if (CurTime() % 1 > 0.5) then
				surface.SetDrawColor(PerfectCams.Colors.Red)
				surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
				surface.DrawTexturedRect(cameraX + cameraW - padding - 95, cameraY + padding + 15, 20, 20)
			end
		else
			PerfectCams.UI.RoundedImage(40, cameraX, cameraY, cameraW, cameraH)
				surface.SetDrawColor(255, 255, 255, 110)
				surface.SetMaterial(PerfectCams.Core.GetImage("static"))
				surface.DrawTexturedRectRotated(cameraX + (cameraW * 0.5), cameraY + (cameraH * 0.5), cameraW * 1.6, cameraH * 1.6, (math.random(1, 4) * 90) - 90)
				draw.SimpleText(PerfectCams.Translation.Screen.CameraDisconnected, "pCams.Screen.Title", cameraX + (cameraW * 0.5), cameraY + (cameraH * 0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			PerfectCams.UI.RoundedImageEnd()
		end
	else
		draw.RoundedBox(20, cameraX, cameraY, cameraW, cameraH, PerfectCams.Colors.GrayLight)
		draw.SimpleText(PerfectCams.Translation.Screen.NoCameraFound, "pCams.Screen.Title", cameraX + (cameraW * 0.5), cameraY + (cameraH * 0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	-- Extra buttons
	if (!self.garbage.buttons['extra_linkt']) then
		self.garbage.buttons['extra_linkt'] = PerfectCams.UI.New3DButton()
			:SetPos(x + w - padding - 210, y + h - 50)
			:SetSize(50, 50)
			:DoClick(function()
				self.garbage.sharePopup = true
			end)
		self.garbage.buttons['extra_linkt'].paint = function(self, x, y, w, h)
			surface.SetDrawColor(PerfectCams.Colors.Red)
			surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
			surface.DrawTexturedRect(x, y, w, h)
	
			surface.SetDrawColor(color_white)
			surface.SetMaterial(PerfectCams.Core.GetImage("link"))
			surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
		end
	end
	self.garbage.buttons['extra_linkt']:Paint(self.garbage.buttons['extra_linkt'].paint)
	
	if (!self.garbage.buttons['extra_share']) then
		self.garbage.buttons['extra_share'] = PerfectCams.UI.New3DButton()
			:SetPos(x + w - padding - 150, y + h - 50)
			:SetSize(50, 50)
			:DoClick(function()
				self.Device:ChangeApp('share')
			end)
		self.garbage.buttons['extra_share'].paint = function(self, x, y, w, h)
			surface.SetDrawColor(PerfectCams.Colors.Green)
			surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
			surface.DrawTexturedRect(x, y, w, h)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(PerfectCams.Core.GetImage("social"))
			surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
		end
	end
	self.garbage.buttons['extra_share']:Paint(self.garbage.buttons['extra_share'].paint)

	-- Camera controls
	if (!self.garbage.buttons['camera_left']) then
		self.garbage.buttons['camera_left'] = PerfectCams.UI.New3DButton()
			:SetPos(x + w - padding - 90, y + h - 50)
			:SetSize(50, 50)
			:DoClick(function()
				self:PrevCamera()
			end)
		self.garbage.buttons['camera_left'].paint = function(self, x, y, w, h)
			surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
			surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
			surface.DrawTexturedRect(x, y, w, h)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(PerfectCams.Core.GetImage("arrow_left"))
			surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
		end
	end
	self.garbage.buttons['camera_left']:Paint(self.garbage.buttons['camera_left'].paint)


	if (!self.garbage.buttons['camera_right']) then
		self.garbage.buttons['camera_right'] = PerfectCams.UI.New3DButton()
			:SetPos(x + w - 50, y + h - 50)
			:SetSize(50, 50)
			:DoClick(function()
				self:NextCamera()
			end)
		self.garbage.buttons['camera_right'].paint = function(self, x, y, w, h)
			surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
			surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
			surface.DrawTexturedRect(x, y, w, h)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(PerfectCams.Core.GetImage("arrow_right"))
			surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
		end
	end
	self.garbage.buttons['camera_right']:Paint(self.garbage.buttons['camera_right'].paint)



	local popupX, popupY, popupW, popupH = x + (w*0.3), y + (h*0.1), w*0.4, h*0.8

	if (self.garbage.sharePopup) then
		draw.RoundedBox(0, x, y, w, h, transBackground)

		draw.RoundedBox(20, popupX, popupY, popupW, popupH, PerfectCams.Colors.Black)

		draw.SimpleText(PerfectCams.Translation.Screen.LinkT, "pCams.Screen.Title", popupX + (popupW * 0.5), popupY + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(PerfectCams.Translation.Screen.LinkTDesc, "pCams.Screen.SubTitle", popupX + (popupW * 0.5), popupY + 55, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		

		if (!self.garbage.buttons['linkt_popup_close']) then
			self.garbage.buttons['linkt_popup_close'] = PerfectCams.UI.New3DButton()
				:SetPos(popupX + popupW - 50, popupY)
				:SetSize(50, 50)
				:DoClick(function()
					self.garbage.sharePopup = false
				end)
			self.garbage.buttons['linkt_popup_close'].paint = function(self, x, y, w, h)
				draw.SimpleText('X', "pCams.Screen.SubTitle", x + (w * 0.5), y + (h * 0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
		self.garbage.buttons['linkt_popup_close']:Paint(self.garbage.buttons['linkt_popup_close'].paint)


		self.garbage.LinkTScroll:SetPos(popupX + 20, popupY + 100)
			:SetSize(popupW - 40, popupH - 120)
		self.garbage.LinkTScroll.items = {}

		local plyPos = localPly:GetPos()

		local chunks = PerfectCams.Config.LinkT.ShareDistance/4

		for k, v in pairs(PerfectCams.Cache.TVs) do
			if (not IsValid(v)) then continue end

			local distance = v:GetPos():DistToSqr(plyPos)

			if (distance > PerfectCams.Config.LinkT.ShareDistance) then continue end
			
			if (!self.garbage.buttons['linkt_popup_tv_' .. v:EntIndex()]) then
				self.garbage.buttons['linkt_popup_tv_' .. v:EntIndex()] = PerfectCams.UI.New3DButton()
				:DoClick(function()
					net.Start("pCams:Phone:LinkT:Cast")
						net.WriteEntity(v)
						net.WriteEntity(ents.GetByIndex(self.garbage.camera.entIndex))
					net.SendToServer()

					self.garbage.sharePopup = false
				end)
				self.garbage.buttons['linkt_popup_tv_' .. v:EntIndex()].paint = function(self, x, y, w, h)
					local distance = v:GetPos():DistToSqr(localPly:GetPos())
					local bars = math.ceil(distance/chunks)

					draw.RoundedBox(10, x, y, w, h, PerfectCams.Colors.GrayLight)
		
					draw.SimpleText(PerfectCams.Translation.Screen.TV, "pCams.Screen.Text", x + 10, y + 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					surface.SetDrawColor(color_white)
					surface.SetMaterial(PerfectCams.Core.GetImage("wifi_" .. bars))
					surface.DrawTexturedRect(x + w - 55, y + 10, 50, 50, 0)
				end
			end

			self.garbage.LinkTScroll:AddItem(self.garbage.buttons['linkt_popup_tv_' .. v:EntIndex()])
		end

		self.garbage.LinkTScroll:Paint()
	end
end


-- Custom methods

-- So over complicated just to get the next key, I love glua :)
function APP:NextCamera()
	local first = false
	local target = false

	local entIndex = 0

	if (self.garbage.camera and self.garbage.camera.entIndex) then
		entIndex = self.garbage.camera.entIndex
	end
	
	for k, v in SortedPairs(PerfectCams.Cameras) do
		if (not first) then
			first = v
		end

		if (v.entIndex > entIndex) then
			target = v
			break
		end
	end

	self.garbage.camera = target or first
end

function APP:PrevCamera()
	local last = false
	local target = false

	local entIndex = 0

	if (self.garbage.camera and self.garbage.camera.entIndex) then
		entIndex = self.garbage.camera.entIndex
	end

	for k, v in SortedPairs(PerfectCams.Cameras, true) do
		if (not last) then
			last = v
		end

		if (v.entIndex < entIndex) then
			target = v
			break
		end
	end

	self.garbage.camera = target or last
end


return APP -- Returning the APP will have pCams auto register it.

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
