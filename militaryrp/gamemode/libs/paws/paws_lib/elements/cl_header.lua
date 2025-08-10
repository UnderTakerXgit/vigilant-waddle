local MODULE = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

local CloseMaterial = Material('icon16/cancel.png')
local AdditionMaterial = Material('icon16/cog.png')

function MODULE:VGUIHeader(parent, text1, font1, color1, text2, font2, color2, addclick, addmaterial)
    local header = vgui.Create('DPanel', parent)
    header:TDLib()
        :ClearPaint()
        :Stick(TOP)


    //header:SetWide(parent:GetWide())
    header:SetTall(70)
    header:SetPos(0, 0)

    local header_text = vgui.Create('DPanel', header)
    header_text:TDLib()
        :Stick(FILL, 5)
        :ClearPaint()
        :DualText(  text1, font1, color1,
                    text2, font2, color2,
                    TEXT_ALIGN_LEFT)

    local header_line = vgui.Create('DPanel', header)
    header_line:TDLib()
        :ClearPaint()
        :SmartStick(BOTTOM, 5, 0, 5)
        :Background(Color(255, 209, 56), 4)
        :SetTall(6)

    local CloseButton = vgui.Create('DButton', header_text)
    CloseButton:TDLib()
        :Stick(RIGHT, 5)
        :ClearPaint()
        :Circle(Colors.Button)
        :CircleExpandHover(Color(255, 255, 255, 10), 15)
        :Text('')
        :On('Paint', function(s, w, h)
            surface.SetDrawColor( 255, 255, 255 )

            surface.SetMaterial( CloseMaterial )
            surface.DrawTexturedRect( w/2-8, h/2-8, 16, 16 )
        end)
        :SetRemove(parent)
    CloseButton:SetSize(32, 32)

    local AdditionButton = vgui.Create('DButton', header_text)
    AdditionButton:TDLib()
        :Stick(RIGHT, 5)
        :ClearPaint()
        :Circle(Color(51,51,51))
        :Text('')
        :CircleExpandHover(Color(255, 255, 255, 10), 15)
        :On('Paint', function(s, w, h)
            surface.SetDrawColor( 255, 255, 255 )

            surface.SetMaterial( addmaterial or AdditionMaterial )
            surface.DrawTexturedRect( w/2-8, h/2-8, 16, 16 )
        end)
        :On('DoClick', function(s) if addclick then addclick(s) end end)
    AdditionButton:SetSize(32, 32)

    function header:SetClose(pnl)
        CloseButton:SetRemove(pnl)
    end

    return header
end