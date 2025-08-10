local MODULE = PAW_MODULE('lib')
MODULE.Notifications = MODULE.Notifications or { }
local Colors = MODULE.Config.Colors

local standardIcons = {
  [NOTIFY_GENERIC] = Material('vgui/notices/generic'),
  [NOTIFY_ERROR] = Material('vgui/notices/error'),
  [NOTIFY_UNDO] = Material('vgui/notices/undo'),
  [NOTIFY_HINT] = Material('vgui/notices/hint'),
  [NOTIFY_CLEANUP] = Material('vgui/notices/cleanup')
}

local PANEL = {}

AccessorFunc(PANEL, 'm_progressColor', 'Color')
AccessorFunc(PANEL, 'm_animTime', 'AnimTime')
AccessorFunc(PANEL, 'm_iconColor', 'IconColor')

function PANEL:Init()
    self.textColor = Color(225, 225, 225)
    self:SetAnimTime(0.2)
 --   self:SetColor(XeninUI.Theme.Accent)
    self:SetIconColor(color_white)

    self.icon = vgui.Create('Panel', self)
    self.icon.Paint = function(pnl, w, h)
        if (!self.img or type(self.img) != 'IMaterial') then return end

        surface.SetDrawColor(self:GetIconColor())
        surface.SetMaterial(self.img)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.label = vgui.Create('DLabel', self)
    self.label:SetText('')
    self.label:SetFont('font_sans_21')
    self.label:SetTextColor(self.textColor)

    self:SetZPos( -50 )
end

function PANEL:SetIcon(icon)
    self.img = icon
end

function PANEL:SetAvatar(ply)
    self.icon = vgui.Create('DPanel', self)
    self.icon:DockMargin(8, 8, 8, 8)
    self.icon:TDLib()
        :CircleAvatar()
        :SetPlayer(ply, 184)

    self.icon:SetWide(self.icon:GetTall())

    self:InvalidateLayout()
end

function PANEL:SetTextColor(col)
    self.label:SetTextColor(col)
end

function PANEL:SetText(text)
    if (istable(text)) then
        self.markup = text
        self.label:SetVisible(false)
    else
        self.label:SetText(text)
        self.label:SizeToContents()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(h / 5, 0, 0, w, h, Colors.Base) 

    local start = self.startTime
    local current = SysTime()
  --  local timeLeft = current - start

  --  local width = timeLeft * (w / self.duration)

    local x, y = self:LocalToScreen()
 --   render.SetScissorRect(x, y, x + w - width, y + h, true)
        draw.RoundedBox(h / 5, 0, 0, w, h, self:GetColor())
    render.SetScissorRect(0, 0, 0, 0, false)

    if (self.markup) then
        self.markup:Draw(8 + (h - 4 - 8) + 4, h / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:Close()
    local id = self.id
    table.remove(MODULE.Notifications, id)
    hook.Run('Paws.NotificationRemoved')

    self:LerpMove(ScrW() + self:GetWide(), self.y, self:GetAnimTime(), function()
        if (!IsValid(self)) then return end

        self:Remove()
    end)
end

function PANEL:SetDuration(time)
    self.duration = time
    self.startTime = SysTime()

    timer.Simple(time, function()
        if (!IsValid(self)) then return end

        self:Close()
    end)
end

function PANEL:PerformLayout(w, h)
    self.icon:SetPos(8, 6)
    self.icon:SetWide(h - 4 - 8)
    self.icon:SetTall(self.icon:GetWide())

    self.label:SetWide(w - self.icon:GetWide() - 8)
    self.label:SetPos(self.icon.x + self.icon:GetWide() + 6, 8)
end

function PANEL:StartNotification()
  local text = self.label:GetText()
  surface.SetFont('font_sans_21')
  local tw, th = surface.GetTextSize(text)
  local width = 8 + 24 + 8 + tw + 8
  if (self.markup) then
    width = width + self.markup:GetWidth()
  end
  local x = ScrW() + width
  local y = ScrH() - 200
  local offset = (self.id - 1) * 45
  y = y - offset

  self:SetSize(width, 36)
  self:SetPos(x, y)
  self:LerpMove(ScrW() - width - 20, y, self:GetAnimTime())
end

vgui.Register('Paws.Notification', PANEL, 'Panel')

function MODULE:Notify(text, icon, duration, progressColor, textColor)
    text = text or 'No Notification Text'
    icon = icon or Material('__error')
    duration = duration or 4
    progressColor = progressColor or Colors.ButtonHover
    textColor = textColor or Colors.Text
    iconColor = iconColor or color_white

    local panel = vgui.Create('Paws.Notification')
    panel.Start = SysTime()
    panel:SetSize(width, 36)
    panel:SetPos(x, y)
    panel:SetText(text)
    panel:SetColor(progressColor)
    if (isnumber(icon)) then
        panel:SetIcon(standardIcons[icon])
    elseif (isstring(icon)) then
        panel:SetIcon(Material(icon, 'smooth'))
    elseif (IsValid(icon) and icon:IsPlayer()) then
        panel:SetAvatar(icon)
    else
        panel:SetIcon(icon)
    end
    panel:SetTextColor(textColor)
    panel:SetIconColor(iconColor)
    panel:SetDuration(duration)
    local id = table.insert(self.Notifications, panel)
    panel.id = id
    self.Notifications[id].id = id
    panel:StartNotification()
end

hook.Add('Paws.NotificationRemoved', 'Core', function()
    for i, v in ipairs(MODULE.Notifications) do
        if (v == NULL) then
            MODULE.Notifications[i] = nil
        end
        if (!IsValid(v)) then continue end
        if (v.removing) then continue end

        v.id = i

        local y = ScrH() - 200
        local offset = (v.id - 1) * 45
        y = y - offset

        v:LerpMoveY(y, v:GetAnimTime())
    end
end)
 
local oldNotification = notification.AddLegacy
function notification.AddLegacy(text, type, length)
    MODULE:Notify(text, type, length)
end