-- cl_inventory.lua (з підтримкою spawnicon, icon16 і тексту)

local inventoryUI
local draggedSlot = nil
local draggedIndex = nil
local dragGhost = nil
local currentInventory = {}

local function SaveInventory()
    net.Start("SaveInventory")
    net.WriteTable(currentInventory)
    net.SendToServer()
end

net.Receive("ClientUpdateSlot", function()
    local index = net.ReadUInt(6)
    local value = net.ReadType()
    currentInventory[index] = value
end)

local function UpdateSlot(index, value)
    currentInventory[index] = value
    net.Start("UpdateInventorySlot")
        net.WriteUInt(index, 6)
        net.WriteType(value)
    net.SendToServer()
end

local function CreateStyledContextMenu(slotPanel)
    local menu = DermaMenu()
    menu.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(30, 30, 30, 230))
    end

    local options = {
        { icon = "🗑", label = "Викинути", color = Color(200, 50, 50), func = function()
            if not slotPanel.itemData then return end
                
            -- Відправити на сервер команду на дроп
            net.Start("Inventory:DropItem")
                net.WriteUInt(slotPanel.slotIndex, 6)
            net.SendToServer()
                
            slotPanel.itemData = nil
            slotPanel:Refresh()
            currentInventory[slotPanel.slotIndex] = nil
        end },
        { icon = "✔", label = "Використати", color = Color(50, 200, 100), func = function()
            chat.AddText("[DEBUG] Використати предмет: " .. tostring(slotPanel.itemData))
        end },
        { icon = "÷", label = "Розділити", color = Color(100, 100, 255), func = function()
            chat.AddText("[DEBUG] Розділити предмет: " .. tostring(slotPanel.itemData))
        end }
    }

    for _, opt in ipairs(options) do
        local btn = menu:AddOption("", opt.func)
        btn:SetText("")
        btn:SetWide(200)
        btn:SetFont("DermaDefaultBold")
        btn.Paint = function(self, w, h)
            local clr = self.Hovered and ColorAlpha(opt.color, 60) or Color(0, 0, 0, 0)
            draw.RoundedBox(4, 0, 0, w, h, clr)
            draw.SimpleText(opt.icon .. "  " .. opt.label, "DermaDefaultBold", 10, h / 2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    menu:SetMinimumWidth(200)
    menu:Open()
    menu:SetPos(gui.MouseX() + 5, gui.MouseY() + 5)
end

net.Receive("InventoryData", function()
    local inv = net.ReadTable()
    if not istable(inv) then return end
    currentInventory = inv

    if IsValid(inventoryUI) then inventoryUI:Remove() end
    if IsValid(dragGhost) then dragGhost:Remove() end

    inventoryUI = vgui.Create("DFrame")
    inventoryUI:SetSize(420, 700)
    inventoryUI:Center()
    inventoryUI:MakePopup()
    inventoryUI:SetTitle("")
    inventoryUI:ShowCloseButton(true)
    inventoryUI:SetDraggable(true)

    inventoryUI:TDLib()
        :ClearPaint()
        :Background(Color(40, 40, 40, 230))
        :FadeIn()

    local title = vgui.Create("DLabel", inventoryUI)
    title:SetText("ИНВЕНТАРЬ")
    title:SetFont("font_sans_35")
    title:SetTextColor(Color(255, 255, 255))
    title:SizeToContents()
    title:SetPos((inventoryUI:GetWide() - title:GetWide()) / 2, 10)

    local grid = vgui.Create("DIconLayout", inventoryUI)
    grid:SetPos(25, 70)
    grid:SetSize(370, 595)
    grid:SetSpaceX(5)
    grid:SetSpaceY(5)

    for i = 1, 35 do
        local item = inv[i]
        local slot = vgui.Create("DPanel", grid)
        slot:SetSize(70, 70)
        slot.slotIndex = i
        slot.itemData = item
        slot.isDropZone = true

        function slot:Refresh()
            self:Clear()
            self:TDLib()
                :ClearPaint()
                :Background(self.itemData and Color(80, 110, 80, 180) or Color(60, 60, 60, 150))
                :CircleClick()
                
            local id = self.itemData
            if istable(id) then id = id.id end
            local meta = ItemRegistry and ItemRegistry[id] or {}

            if meta.model then
                local icon = vgui.Create("SpawnIcon", self)
                icon:SetSize(64, 64)
                icon:SetPos(3, 3)
                icon:SetModel(meta.model)
            elseif isstring(self.itemData) and file.Exists("materials/icon16/" .. self.itemData .. ".png", "GAME") then
                local icon = vgui.Create("DImage", self)
                icon:SetSize(32, 32)
                icon:SetPos((70 - 32)/2, (70 - 32)/2)
                icon:SetImage("icon16/" .. self.itemData .. ".png")
            else
                self:Text(meta.name or id or "?", "font_sans_18", Color(255,255,255), TEXT_ALIGN_CENTER)
            end
        end

        slot:Refresh()

        slot.OnMousePressed = function(self, code)
            if code == MOUSE_LEFT and self.itemData then
                draggedSlot = self
                draggedIndex = self.slotIndex

                if IsValid(dragGhost) then dragGhost:Remove() end
                dragGhost = vgui.Create("DPanel")
                dragGhost:SetSize(70, 70)
                dragGhost:SetAlpha(0)

                dragGhost:TDLib()
                    :ClearPaint()
                    :Background(Color(100, 200, 100, 200))
                    :Text(self.itemData or "?", "font_sans_18", Color(255,255,255), TEXT_ALIGN_CENTER)
                    :FadeIn(0.1)

                dragGhost.PaintOver = function(s, w, h)
                    local x, y = input.GetCursorPos()
                    s:SetPos(x - w/2, y - h/2)
                end
            elseif code == MOUSE_RIGHT and self.itemData then
                CreateStyledContextMenu(self)
            end
        end

        slot.OnMouseReleased = function(self, code)
            if code == MOUSE_LEFT and draggedSlot then
                if self:IsHovered() and self ~= draggedSlot then
                    local tmp = self.itemData
                    self.itemData = draggedSlot.itemData
                    draggedSlot.itemData = tmp

                    self:Refresh()
                    draggedSlot:Refresh()

                    currentInventory[self.slotIndex] = self.itemData
                    currentInventory[draggedSlot.slotIndex] = draggedSlot.itemData
                    SaveInventory()
                end
            end

            if IsValid(dragGhost) then
                dragGhost:AlphaTo(0, 0.2, 0, function()
                    if IsValid(dragGhost) then dragGhost:Remove() end
                end)
            end

            draggedSlot = nil
            draggedIndex = nil
        end
    end
end)

hook.Add("PlayerButtonDown", "OpenInventoryKey", function(ply, key)
    if key == KEY_I and not vgui.CursorVisible() then
        net.Start("OpenInventory")
        net.SendToServer()
    end
end)
