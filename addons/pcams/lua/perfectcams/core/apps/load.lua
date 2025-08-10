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

APP.UniqueName = "load" -- This is a unique name with no special characters or uppercase (Excluding _)
APP.Name = "Load" -- Give the app a display name
APP.ShowOnHUB = false -- Should the app show on the HUB?
APP.HideSidebar = true

-- This is called when the app is opened
function APP:Load()
	self.garbage.loadWidth = 0
	self.garbage.loadHeight = 5
	self.garbage.loadImage = 0

	timer.Simple(3, function()
		if not IsValid(self.Device) then return end

		self.Device:ChangeApp("hub")
	end)
end

-- This is called when the app is closed.
-- Note: It is not called on events like SWEP change or unexpected turn off. Only when the app is exited back into the HUB
function APP:Close()
end

-- Paint the thumbnail to be shown on the HUB (Not needed if not shown on HUB)
function APP:PaintThumbnail(w, h)
end

-- This is the function that is called while the app is open, and is shown "full screen". You should do all your
-- interface and logic here. This is basically the heart of the app.
function APP:Render(x, y, w, h)
	-- Set the speed
	local speed = FrameTime() * 3

	-- Once width is complete run height
	if not (self.garbage.loadWidth == w) then
	self.garbage.loadWidth = math.ceil(math.Approach(self.garbage.loadWidth, w, w*speed))

	elseif (self.garbage.loadWidth == w) and not (self.garbage.loadHeight == h) then
		self.garbage.loadHeight = math.ceil(math.Approach(self.garbage.loadHeight, h, h*speed))
	-- Once width and height is complete run logo
	elseif (self.garbage.loadWidth == w) and (self.garbage.loadHeight == h) then
		self.garbage.loadImage = math.ceil(math.Approach(self.garbage.loadImage, 255, 255 * (FrameTime()*0.5)))
	end

	-- Render background first
	draw.RoundedBox(0, (w*0.5) - (self.garbage.loadWidth*0.5), (h*0.5) - (self.garbage.loadHeight*0.5), self.garbage.loadWidth, self.garbage.loadHeight, PerfectCams.Colors.Gray)

	-- Render logo
	local logoMat = PerfectCams.Core.GetImage("phone_logo")
	surface.SetDrawColor(255, 255, 255, self.garbage.loadImage)
	surface.SetMaterial(logoMat)
	surface.DrawTexturedRectRotated(w*0.5, h*0.5, 791, 256, 0)
end


return APP -- Returning the APP will have pCams auto register it.

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
