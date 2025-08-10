local PANEL = {}

function PANEL:Init()    
    self.VBar:SetWide(12)
    self.VBar:SetHideButtons(true)

    self.VBar.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(PawsUI.Theme.ScrollDarkBlue, 150))
    end
    self.VBar.btnGrip.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, PawsUI.Theme.ScrollBlue)
    end
end
 
vgui.Register('PawsUI.ScrollPanel', PANEL, 'DScrollPanel')

