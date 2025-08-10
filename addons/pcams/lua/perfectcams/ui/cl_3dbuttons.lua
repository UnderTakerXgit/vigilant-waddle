--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

local class = {}
local methods = {}

function PerfectCams.UI.New3DButton()
    local data = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        clicked = false,
        callback = function() end,
        paint = false
    }

    setmetatable(data, class)

    return data
end

function class.__tostring(self)
	
    return "[3D Button]"..util.TableToJSON(self,true)
end

function methods.SetPos(self, x, y)
	self.x = x
	self.y = y

	return self 
end

function methods.SetSize(self, w, h)
	self.width = w
	self.height = h 

	return self 
end

function methods.DoClick(self, callback)
	self.callback = callback

	return self
end

function methods.Paint(self, paint)
    self.hover = PerfectCams.Libs.Imgui.IsHovering(self.x, self.y, self.width, self.height)

    if (input.IsMouseDown(MOUSE_LEFT) and self.hover and !self.clicked and !PerfectCams.Cooldown.Check('3DButtons:Click', 0.3)) then
        self.clicked = true
    
        self.callback()
    else
        self.clicked = input.IsMouseDown(MOUSE_LEFT)
    end

	if (isfunction(paint)) then
        paint(self, self.x, self.y, self.width, self.height)
    elseif (self.paint) then
        self.paint(self, self.x, self.y, self.width, self.height)
    end
end

class.__index = methods

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
