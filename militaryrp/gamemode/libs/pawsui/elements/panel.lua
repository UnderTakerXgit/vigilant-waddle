local PANEL = {}

function PANEL:Init()
    self:TDLib()
        :ClearPaint()
end

vgui.Register('PawsUI.Panel', PANEL, 'EditablePanel')

