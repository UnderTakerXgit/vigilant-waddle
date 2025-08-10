local MODULE = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

local PANEL = {}

function PANEL:Init()
    self:TDLib()
end

function PANEL:Create(text, font)
    self:ClearPaint()
        :Background(Colors.Button)
        :FadeHover(Colors.ButtonHover)
        :Text(text, font)

    return self
end

function PANEL:SetClose(p)
    self:ClearPaint()
        :Background(Colors.Button)
        :FadeHover(Colors.CloseHover)
        :SetRemove(p)
        :Text('Закрыть', 'font_sans_16')

    return self
end

vgui.Register('Paws.Button', PANEL, 'DButton')