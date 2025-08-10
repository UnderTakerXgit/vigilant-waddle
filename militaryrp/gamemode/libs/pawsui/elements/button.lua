local PANEL = {}

surface.CreateFont('PawsUI.Button', {
    font = 'Open Sans',
    size = 21,
    weight = 500,
    extended = true
})

function PANEL:Init()
    
    self:SetFont('PawsUI.Button')
    self:SetText('') 

    self:SetTall(25)

    self.m_Text = 'Label'
    self.m_Color = PawsUI.Theme.Text

    self:TDLib()
        :ClearPaint()
        :Background(PawsUI.Theme.DarkBlue)
        :FadeHover(PawsUI.Theme.Blue)
        :CircleClick(PawsUI.Theme.AlphaWhite)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'PawsUI.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        :On('OnCursorEntered', function(s) s:LerpColor('m_Color', PawsUI.Theme.HoveredText) end)
        :On('OnCursorExited', function(s) s:LerpColor('m_Color', PawsUI.Theme.Text) end)
end

function PANEL:Restore()
    self:ClearPaint()
        :Background(PawsUI.Theme.DarkBlue)
        :FadeHover(PawsUI.Theme.Blue)
        :CircleClick(PawsUI.Theme.AlphaWhite)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'PawsUI.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
end

function PANEL:SetBackground(bgColor, hoverColor)
    self:ClearPaint()
        :Background(bgColor or PawsUI.Theme.DarkBlue)
        :FadeHover(hoverColor or PawsUI.Theme.Blue)
        :CircleClick(PawsUI.Theme.AlphaWhite)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'PawsUI.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
end
 
function PANEL:SetLabel(str)
    self.m_Text = str
    self:InvalidateLayout(true)
end

vgui.Register('PawsUI.Button', PANEL, 'DButton')