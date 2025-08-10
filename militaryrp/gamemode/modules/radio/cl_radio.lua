local ui = {} 
ui.UI = ui.UI or nil

NextRP.Radio = ui

local LIB = PAW_MODULE('lib')
local W, H = ScrW, ScrH

local radio_on = Material('radio/radio_state_on.png', 'mips smooth')
local radio_off = Material('radio/radio_state_off.png', 'mips smooth')

local function DrawFlexText( colors, font, x, y )
	surface.SetFont( font )
	surface.SetTextPos( x, y )

	for k, v in ipairs(colors) do
		local col = v[2]
		surface.SetTextColor( col.r, col.g, col.b, col.a or 255 )
		surface.DrawText( tostring(v[1])..' ' )
	end
end

function ui:open()
    if IsValid(ui.UI) then ui.UI:Remove() end
    if IsValid(ui.Blur) then return end

    ui.Blur = TDLib('DPanel')
        :ClearPaint()
        :Blur()

    ui.Blur:SetSize(W(), H())

    ui.UI = TDLib('DFrame')
        :ClearPaint()
        :Background(Color(40, 40, 40, 150))
        :FadeIn()
        :On('Paint', function(s, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, -75, 640, 360)

            draw.DrawText('Комлинк', 'font_sans_21', w*.5, 180, PawsUI.Theme.Text, TEXT_ALIGN_CENTER)

            DrawFlexText({
                {
                   'Состояние: ',
                    PawsUI.Theme.Text
                },
                {
                    LocalPlayer():GetSpeaker() and 'Включён' or 'Выключен',
                    LocalPlayer():GetSpeaker() and PawsUI.Theme.Green or PawsUI.Theme.LightRed
                }
            }, 'font_sans_21', 50, 220)

            DrawFlexText({
                {
                   'Частота: ',
                    PawsUI.Theme.Text
                },
                {
                    LocalPlayer():GetFrequency(),
                    PawsUI.Theme.Gold
                }
            }, 'font_sans_21', 480, 220)
        end)
    ui.UI:SetSize(640, 270)
    ui.UI:SetPos(0, 0)
    ui.UI:MakePopup()
    ui.UI:SetTitle('')
    ui.UI:ShowCloseButton(false)
    ui.UI:SetDraggable(false)
    ui.UI:Center()

    function ui.UI:OnRemove()
        ui.Blur:FadeOut()
        timer.Simple(.1, function() ui.Blur:Remove() end)
    end

    local StatusButton = TDLib('DButton', ui.UI)
        :ClearPaint()
        :Background(Color(40, 40, 40, 150))
        :FadeHover()
        :CircleClick()
        :BarHover(PawsUI.Theme.Gold)
        :Text('Вкл/Выкл', 'font_sans_16')
        :On('DoClick', function()
            LocalPlayer():SetSpeaker(!LocalPlayer():GetSpeaker())
        end)

    StatusButton:SetPos(ui.UI:GetWide()*.5 - 64 - 2, 210)
    StatusButton:SetSize(64,44)

    local FreqButton = TDLib('DButton', ui.UI)
        :ClearPaint()
        :Background(Color(40, 40, 40, 150))
        :FadeHover()
        :CircleClick()
        :BarHover(PawsUI.Theme.Gold)
        :Text('Частота', 'font_sans_16')
        :On('DoClick', function()
            LIB:DoStringRequest('Частота', 'Введите частоту для рации', LocalPlayer():GetFrequency(), function(sValue)
                if tonumber(sValue) == nil then return end
                if tonumber(sValue) <= 0 then return end

                sValue = string.Replace(sValue, ',', '.')
                sValue = tonumber(sValue)
                sValue = math.Round(sValue, 1)
                sValue = tostring(sValue)

                LocalPlayer():SetFrequency(sValue)
            end, nil, 'Ввести', 'Отмена')
        end)

    FreqButton:SetPos(ui.UI:GetWide()*.5 + 2 , 210)
    FreqButton:SetSize(64,44)

    local close = TDLib('DButton', ui.UI)
        :Text('', 'font_sans_16')
        :SetRemove(ui.UI)
        :ClearPaint()
        :Background(Color(40,40,40, 200))
        :FadeHover()
        :On('Paint', function(s, w, h)            
            surface.SetDrawColor(color_white)
            surface.SetMaterial(PawsUI.Materials.CloseButton)
            surface.DrawTexturedRect(12, 12, w - 24, h - 24)            
        end)

    close:SetPos(ui.UI:GetWide() - 34, 7)
    close:SetSize(32,32)
end
   

netstream.Hook('NextRP::OpenRadio', function()
    ui:open()
end)