--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

local class = {}
local methods = {}

function PerfectCams.UI.New3DScroll()
    local data = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        scroll = 0,
        scrollHeight = 0,
        items = {},
        itemHeight = 0,
        itemPadding = 0,
        buttons = {}
    }

    setmetatable(data, class)

    return data
end

function class.__tostring(self)
	
    return "[3D Scroll]"..util.TableToJSON(self,true)
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

function methods.SetScrollHeight(self, h)
    self.scrollHeight = h

    return self
end

function methods.AddItem(self, item)
    table.insert(self.items, item)

    self.scrollHeight = (table.Count(self.items) * (self.itemHeight + self.itemPadding)) - self.itemPadding

    return self
end

function methods.SetItemHeight(self, h)
    self.itemHeight = h

    return self
end

function methods.SetItemPadding(self, p)
    self.itemPadding = p

    return self
end

function methods.Paint(self)
    if (!self.buttons['up']) then
        self.buttons['up'] = PerfectCams.UI.New3DButton()
            :SetSize(50, 50)
            :DoClick(function()
                self.scroll = math.Clamp(self.scroll - 50, 0, math.max(self.scrollHeight - self.height + 120, 0))
            end)
        self.buttons['up'].paint = function(self, x, y, w, h)
            surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
            surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
            surface.DrawTexturedRect(x, y, w, h)
    
            surface.SetDrawColor(color_white)
            surface.SetMaterial(PerfectCams.Core.GetImage("arrow_up"))
            surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
        end
    end
    self.buttons['up']
        :SetPos(self.x + (self.width * 0.5) - 25, self.y)
        :Paint(self.buttons['up'].paint)

    if (!self.buttons['down']) then
        self.buttons['down'] = PerfectCams.UI.New3DButton()
            :SetSize(50, 50)
            :DoClick(function()
                self.scroll = math.Clamp(self.scroll + 50, 0, math.max(self.scrollHeight - self.height + 120, 0))
            end)
        self.buttons['down'].paint = function(self, x, y, w, h)
            surface.SetDrawColor(self.hover and PerfectCams.Colors.GrayLight or PerfectCams.Colors.Gray)
            surface.SetMaterial(PerfectCams.Core.GetImage("dot"))
            surface.DrawTexturedRect(x, y, w, h)

            surface.SetDrawColor(color_white)
            surface.SetMaterial(PerfectCams.Core.GetImage("arrow_down"))
            surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 20)
        end
    end
    self.buttons['down']
        :SetPos(self.x + (self.width * 0.5) - 25, self.y + self.height - 50)
        :Paint(self.buttons['down'].paint)


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
        surface.DrawRect(self.x, self.y + 60, self.width, self.height - 120)

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(1)

	//if paint then paint(self, self.x, self.y + 50, self.width, self.height - 100) end 
    for k, v in pairs(self.items) do
        if (isfunction(v)) then
            v(v, self.x, self.y + 60 + ((k - 1) * (self.itemHeight + self.itemPadding)) - self.scroll, self.width, self.itemHeight)
        elseif(v.Paint) then
            v:SetPos(self.x, self.y + 60 + ((k - 1) * (self.itemHeight + self.itemPadding)) - self.scroll)
            v:SetSize(self.width, self.itemHeight)
            v:Paint()
        end
    end

    render.SetStencilEnable(false)
    render.ClearStencil()
end


class.__index = methods

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
