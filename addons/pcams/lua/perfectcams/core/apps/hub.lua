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

APP.UniqueName = "hub" -- This is a unique name with no special characters or uppercase (Excluding _)
APP.Name = "HUB" -- Give the app a display name
APP.ShowOnHUB = false -- Should the app show on the HUB?

-- This is called when the app is opened
function APP:Load()
	self:NextCamera()

	-- Create app buttons
	self.garbage.buttons = {}
	self.garbage.page = 1
	self.garbage.totalApps = 0
	self.garbage.apps = {}
	for k, v in pairs(PerfectCams.Apps.All) do
		if not v.ShowOnHUB then continue end -- Marked as a hidden app
		self.garbage.totalApps = self.garbage.totalApps + 1

		self.garbage.apps[self.garbage.totalApps] = v
	end

	self.garbage.pagesTotal = 1 + math.ceil(self.garbage.totalApps / 8)

	self.garbage.scroll = PerfectCams.UI.New3DScroll()
		:SetItemHeight(70)
		:SetItemPadding(15)
end

-- This is called when the app is closed.
-- Note: It is not called on events like SWEP change or unexpected turn off. Only when the app is exited back into the HUB
function APP:Close()
	PerfectCams.ActiveCamera = nil
end

-- Paint the thumbnail to be shown on the HUB (Not needed if not shown on HUB)
function APP:PaintThumbnail(w, h)
end

-- This is the function that is called while the app is open, and is shown "full screen". You should do all your
-- interface and logic here. This is basically the heart of the app.
local padding = 20
local paginationHeight = 40
local appPadding = 80
function APP:Render(x, y, w, h)
	if (!self.garbage.page) then return end
	if (!self.garbage.scroll) then return end
	if (!self.garbage.buttons) then return end

	-- Draw app icons and their names
	local x, y, w, h = x + padding, y + padding, w - (padding * 2), h - (padding * 2)

	if (self.garbage.page == 1) then
		-- Camera list
		local camerasX, camerasY, camerasW, camerasH = x, y, (w/3) - (padding * 0.5), h - paginationHeight
		//draw.RoundedBox(20, camerasX, camerasY, camerasW, camerasH, PerfectCams.Colors.Gray)
		draw.SimpleText(PerfectCams.Translation.Screen.DashboardCameras, "pCams.Screen.Title", camerasX, camerasY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		self.garbage.scroll:SetPos(camerasX, camerasY + 60)
			:SetSize(camerasW, camerasH - 60)
		self.garbage.scroll.items = {}
		for k, v in SortedPairs(PerfectCams.Cameras) do
			if (!self.garbage.buttons['camera_' .. k]) then
				self.garbage.buttons['camera_' .. k] = PerfectCams.UI.New3DButton()
					:DoClick(function()
						self.Device:ChangeApp('view3r', k)
					end)

				self.garbage.buttons['camera_' .. k].paint = function(self, x, y, w, h)
					draw.RoundedBox(10, x, y, w, h, self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
			
					draw.SimpleText(v.name or PerfectCams.Translation.Screen.Name, "pCams.Screen.Text", x + 10, y + 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
					surface.SetDrawColor(color_white)
					surface.SetMaterial(PerfectCams.Core.GetImage("arrow_up_right"))
					surface.DrawTexturedRect(x + w - 55, y + 10, 50, 50, 0)
				end
			end

			self.garbage.scroll:AddItem(self.garbage.buttons['camera_' .. k])
		end

		self.garbage.scroll:Paint()


		-- Live view of camera
		local liveX, liveY, liveW, liveH =  x + (w/3) + (padding*0.5), y, ((w/3) * 2) - (padding * 0.5), h - paginationHeight

		--draw.RoundedBox(20, liveX, liveY, liveW, liveH, PerfectCams.Colors.Gray)	

		if (self.garbage.camera and self.garbage.camera.entIndex and PerfectCams.Cameras[self.garbage.camera.entIndex]) then
			local ent = ents.GetByIndex(self.garbage.camera.entIndex)
	
			if (IsValid(ent)) then
				-- Draw active camera
				local aspect = ent:GetRTMaterial():Width() / ent:GetRTMaterial():Height()

				PerfectCams.UI.RoundedImage(30, liveX, liveY, liveW, liveH)
					surface.SetMaterial(ent:GetRTMaterial())
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRectRotated(liveX + (liveW * 0.5), liveY + (liveH * 0.5), aspect * liveH, liveH, 0)
				PerfectCams.UI.RoundedImageEnd()
			end

			surface.SetFont("pCams.Screen.Text")
			local width, height = surface.GetTextSize(PerfectCams.Cameras[self.garbage.camera.entIndex].name or PerfectCams.Translation.Screen.Name)
			draw.RoundedBox(10, liveX + 20, liveY + liveH - 65, width + 20, 50, PerfectCams.Colors.Gray)
			draw.SimpleText(PerfectCams.Cameras[self.garbage.camera.entIndex].name or PerfectCams.Translation.Screen.Name, "pCams.Screen.Text", liveX + 30, liveY + liveH - 40, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


			draw.RoundedBox(10, liveX + liveW - 125, liveY + 20, 105, 50, PerfectCams.Colors.Gray)
			draw.SimpleText(PerfectCams.Translation.Screen.Live, "pCams.Screen.Text", liveX + liveW - 30, liveY + 45, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			if (CurTime() % 1 > 0.5) then
				surface.SetDrawColor(PerfectCams.Colors.Red)
				surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
				surface.DrawTexturedRect(liveX + liveW - 115, liveY + 35, 20, 20)
			end
		else 
			draw.RoundedBox(20, liveX, liveY, liveW, liveH, PerfectCams.Colors.GrayLight)
			draw.SimpleText(PerfectCams.Translation.Screen.NoCameraFound, "pCams.Screen.Title", liveX + (liveW * 0.5), liveY + (liveH * 0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- Camera controls
		if (!self.garbage.buttons['camera_left']) then
			self.garbage.buttons['camera_left'] = PerfectCams.UI.New3DButton()
				:SetPos(liveX + liveW - 130, liveY + liveH - 70)
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
				:SetPos(liveX + liveW - 70, liveY + liveH - 70)
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

	else
		-- Render apps
		local appPage = self.garbage.page - 2 -- Sub 2 so we can be at 0 on 2nd page, which is actually first page of apps
		local appsX, appsY, appsW, appsH = x, y + ((h*0.1) - paginationHeight), w, (h * 0.8) - paginationHeight
		local appW, appH = appsH*0.5 - appPadding, appsH*0.6 - appPadding
		local appsWMargin = (appsW - (appW * 4)) / 3

		for i=1, 8 do
			local appIndex = (appPage * 8) + i
			local app = self.garbage.apps[appIndex]
			

			if (!app) then continue end

			local appX = appsX + (appW * (i - 1)) + (appsWMargin * (i - 1)) - ((i > 4) and (appsW + appsWMargin) or 0)
			local appY = appsY + ((i > 4) and (appH + appPadding) or 0)

			if (!self.garbage.buttons['app_' .. app.UniqueName]) then
				self.garbage.buttons['app_' .. app.UniqueName] = PerfectCams.UI.New3DButton()
					:DoClick(function()
						self.Device:ChangeApp(app.UniqueName)
					end)

				self.garbage.buttons['app_' .. app.UniqueName].paint = function(self, x, y, w, h)
					app:PaintThumbnail(x, y, w, w)

					surface.SetFont("pCams.Screen.Text")
					local width, _ = surface.GetTextSize(app.Name)

					draw.RoundedBox(10, x + (w*0.5) - (width * 0.5) - 20, y + h - 40, width + 40, 40, PerfectCams.Colors.Gray)
					draw.SimpleText(app.Name, "pCams.Screen.Text",  x + (w*0.5), y + h - 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
			
			self.garbage.buttons['app_' .. app.UniqueName]
				:SetPos(appX, appY)
				:SetSize(appW, appH)
				:Paint(self.garbage.buttons['app_' .. app.UniqueName].paint)
		end

	end

	-- Pagination
	for i = 1, (self.garbage.pagesTotal or 1) do
		if (!self.garbage.buttons['pagination_' .. i]) then
			self.garbage.buttons['pagination_' .. i] = PerfectCams.UI.New3DButton()
				:SetPos(x + (w*0.5) + (i * 30) - ((self.garbage.pagesTotal or 1) * 15), y + h - 10)
				:SetSize(20, 20)
				:DoClick(function()
					self.garbage.page = i
				end)
			self.garbage.buttons['pagination_' .. i].paint = function(_, x, y, w, h)
				surface.SetDrawColor((i == self.garbage.page) and color_white or PerfectCams.Colors.Gray)
				surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
				surface.DrawTexturedRect(x, y, w, h)
			end
		end

		self.garbage.buttons['pagination_' .. i]:Paint(self.garbage.buttons['pagination_' .. i].paint)
	end
end


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

// Get the previous camera, looping back to the end when at the first camera
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
