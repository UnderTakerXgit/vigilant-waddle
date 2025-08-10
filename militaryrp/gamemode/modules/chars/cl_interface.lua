local DISCORD_LINK = 'https://discord.gg/RQQmTj35ae'
-- Leak by VoLVeR https://vk.com/darkrp_credorp
local ui = {} 
ui.UI = ui.UI or nil

local LIB = PAW_MODULE('lib')

local defaultBtns = {
    ['Персонажи'] = {
        sortOrder = 1,
        active = true,
        click = function(pnl)
            ui:chars(pnl:GetParent(), nil)
            pnl:Remove()
        end
    },
    ['Википедия'] = {
        sortOrder = 2,
        active = false,
        click = function(pnl)
			gui.OpenURL('https://wiki.rephyx.tech/')
		end 
    },
    ['Discord'] = {
        sortOrder = 3,
        active = false,
        click = function(pnl)
            gui.OpenURL(DISCORD_LINK)
        end 
    },
    ['Закрыть'] = {
        sortOrder = 99,
        active = false,
        click = function()
            ui.UI:Remove()
        end,
        align = RIGHT
    }
}
local chars = {
    {
        create = true
    }
}

local message = {
    col = Color(0, 255, 0),
    text = 'Персонажи успешно получены! На сервере могут быть баги.'
}

function textWrap(text, font, pxWidth)
    local total = 0

    surface.SetFont(font)

    local spaceSize = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                total = 0
            end

            local wordlen = surface.GetTextSize(word)
            total = total + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= pxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
                total = splitPoint
                return splitWord
            elseif total < pxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                total = wordlen - spaceSize
                return '\n' .. string.sub(word, 2)
            end

            total = wordlen
            return '\n' .. word
        end)

    return text
end

local faction = {TYPE_GAR}
local factionLocalization = FACTION_LOCALIZATIONS

function ui:open(btns)
    if IsValid(ui.UI) then ui.UI:Remove() end

    ui.UI = TDLib('DFrame')
        :ClearPaint()
        :Background(Color(54, 54, 64))
    ui.UI:SetSize(ScrW(), ScrH())
    ui.UI:Center()
    ui.UI:MakePopup()
    ui.UI:SetTitle('')
    ui.UI:ShowCloseButton(false)
    ui.UI:SetDraggable(false)
    
    local pn = ui:chars(ui.UI)

end
-- Leak by VoLVeR https://vk.com/darkrp_credorp
function ui:header(pnl, buttons)
    local header = TDLib('DPanel', pnl)
        :DivWide(1)
        :ClearPaint()
        :Stick(TOP)

    local msg = TDLib('DPanel', header)
        :Stick(BOTTOM, 2)
        :ClearPaint()
        :Text(message.text, 'font_sans_16', message.col)

    header:SetTall(55 + msg:GetTall())

    local logo = TDLib('DPanel', header)
        :ClearPaint()
        :Text('Rephyx.tech', 'font_sans_35')
    
    logo:Dock(LEFT)
    logo:DockMargin(15, 1, 15, 1)
    logo:SetWide(48)

    LIB:Download('assets_a/logo2.png', 'https://cdn.discordapp.com/icons/1267110058672652361/a6174e96efc701e64669730565f825c7.png', function(dPath)
        local mat = Material(dPath, 'mips smooth')

        if mat:IsError() then return end

        logo
            :ClearPaint()
            :On('Paint', function(s, w, h)
            --    surface.SetMaterial(mat)
             --   surface.SetDrawColor(255, 255, 255, 255)

                surface.DrawTexturedRect(0, h*.5 - 24, 48, 48)
                
            end)
    end, errorCallback)
	
    for k, v in SortedPairsByMemberValue(buttons, 'sortOrder', false) do
        local genButton = TDLib('DButton', header)
            :Stick(v.align or LEFT, 4)
            :ClearPaint()
        
        if v.active then
            genButton:TDLib()
                :Text(k, 'font_sans_21', color_white)
                :SideBlock(color_white, 4, BOTTOM)
                :On('DoClick', function()
                    if v.click then v.click(pnl) end
                end)
        else
            genButton.color = Color(181, 181, 181)
            genButton:TDLib()
                :Text('')
                :BarHover(Color(181, 181, 181), 4)
                :On('DoClick', function()
                    if v.click then v.click(pnl) end
                end)
                :On('Think', function(s)
                    s.color = TDLibUtil.LerpColor(FrameTime() * 12, s.color, s:IsHovered() and color_white or Color(181, 181, 181))
                end)
                :On('Paint', function(s)
                    draw.SimpleText(k, 'font_sans_21', s:GetWide() * 0.5, s:GetTall() * 0.5, s.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end)
        end

        surface.SetFont('font_sans_21')
        local w = surface.GetTextSize(k)

        genButton:SetWide(w + 14)
    end
end

function ui:chars(pnl, buttons)
    local content = TDLib('DPanel', pnl)
        :ClearPaint()

    content:SetPos(5,5)
    content:SetSize(pnl:GetWide() - 10, pnl:GetTall() - 10)

    ui:header(content, buttons or defaultBtns)

    local charBase = TDLib('DHorizontalScroller', content)
        :Stick(FILL, 5)
        :ClearPaint()        

    charBase:SetOverlap(-13)

-- Leak by VoLVeR https://vk.com/darkrp_credorp
    local LEFTSwitch = charBase.btnLeft:TDLib()
        :Stick(LEFT, 5)
        :ClearPaint()
    LIB:Download('nw/left.png', 'https://i.imgur.com/4BvAFTn.png', function(dPath)
        local mat = Material(dPath, 'smooth')
        LEFTSwitch.s = 32
        LEFTSwitch.col = Color(181, 181, 181)
        LEFTSwitch
            :On('Paint', function(s)
                surface.SetMaterial(mat)
                surface.SetDrawColor(s.col)
                surface.DrawTexturedRect(s:GetWide() * 0.5 - s.s * 0.5, s:GetTall() * 0.5 - s.s * 0.5, s.s, s.s)
            end)
            :On('Think', function(s)
                s.col = TDLibUtil.LerpColor(FrameTime() * 12, s.col, s:IsHovered() and color_white or Color(181, 181, 181))
                s.s = Lerp(FrameTime() * 12, s.s, s:IsHovered() and 48 or 32)
                
                s:SetWide(40) -- это ебаный костыль, но мне похуй
                s:AlignLeft( 0 )
            end)
    end)
    local RIGHTSwitch = charBase.btnRight:TDLib()
        :Stick(RIGHT)
        :ClearPaint()

    LIB:Download('nw/right.png', 'https://i.imgur.com/FHqpFEU.png', function(dPath)
        local mat = Material(dPath, 'smooth')
        RIGHTSwitch.s = 32
        RIGHTSwitch.col = Color(181, 181, 181)
        RIGHTSwitch
            :On('Paint', function(s)
                surface.SetMaterial(mat)
                surface.SetDrawColor(s.col)
                surface.DrawTexturedRect(s:GetWide() * 0.5 - s.s * 0.5, s:GetTall() * 0.5 - s.s * 0.5, s.s, s.s)
            end)
            :On('Think', function(s)
                s.col = TDLibUtil.LerpColor(FrameTime() * 12, s.col, s:IsHovered() and color_white or Color(181, 181, 181))
                s.s = Lerp(FrameTime() * 12, s.s, s:IsHovered() and 48 or 32)
                
                s:SetWide(40) -- это ебаный костыль, но мне похуй
                s:AlignRight( 0 )
            end)
    end)

    for k, v in ipairs(chars) do
        local char = TDLib('DPanel')
            :ClearPaint()
            :Background(Color(53 - 15, 57 - 15, 68 - 15, 40))

        char:SetWide((charBase:GetWide() - 40) / 4)

        charBase:AddPanel(char) -- Добавить в скроллер

        if v.create then
            local icon = TDLib('DPanel', char)
                :ClearPaint()
            
            -- инфа для анимаций
            icon.s = 64
            icon.col = color_white

            -- позиционирование
            icon:SetSize(char:GetWide(), 240)
            icon:SetPos(char:GetWide() * 0.5 - icon:GetWide() * 0.5, char:GetTall() * 0.5 - 180 * 0.5)
            
            LIB:Download('nw/add_v2.png', 'https://i.imgur.com/q8OyHg8.png', function(dPath)
                local mat = Material(dPath, 'smooth noclamp')
                
                icon
                    :On('Paint', function(s)
                        surface.SetMaterial(mat)
                        surface.SetDrawColor(icon.col)
                        surface.DrawTexturedRect(icon:GetWide() * 0.5 - icon.s * 0.5, 180 * 0.5 - icon.s * 0.5, icon.s, icon.s)

                        draw.DrawText(textWrap('Нажмите сюда, что-бы создать нового персонажа.', 'font_sans_21', icon:GetWide() - 20), 'font_sans_21', s:GetWide() * 0.5, icon.s * 0.5 + 100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)                
            end)

            local chooseButton = TDLib('DButton', char)
                :ClearPaint()
                :Text('')
                :LinedCorners(Color(181, 181, 181), 50)
                :On('Think', function(s)
                    icon.col = TDLibUtil.LerpColor(FrameTime() * 12, icon.col, s:IsHovered() and Color(79, 150, 219) or color_white)
                    icon.s = Lerp(FrameTime() * 12, icon.s, s:IsHovered() and 128 or 64)
                end)
                :On('DoClick', function(s)
                    content:Remove()
                    ui:new(pnl)
                end)

            chooseButton:SetSize(char:GetSize())
        
        elseif v.locked then
            local icon = TDLib('DPanel', char)
                :ClearPaint()
            -- инфа для анимаций
            icon.s = 64
            icon.col = color_white

            -- позиционирование
            icon:SetSize(char:GetWide(), 250)
            icon:SetPos(char:GetWide() * 0.5 - icon:GetWide() * 0.5, char:GetTall() * 0.5 - 180 * 0.5)
            
            LIB:Download('nw/locked.png', 'https://i.imgur.com/IBCN0UC.png', function(dPath)
                icon.mat = Material(dPath, 'smooth noclamp')
                icon.text = 'Недоступный слот.\nПриобрести дополнительный слот, вы можете в donate-menu'
                icon.cantafford = false

                icon
                    :On('Paint', function(s)
                        surface.SetMaterial(icon.mat)
                        surface.SetDrawColor(icon.col)
                        surface.DrawTexturedRect(icon:GetWide() * 0.5 - icon.s * 0.5, 180 * 0.5 - icon.s * 0.5, icon.s, icon.s)

                        draw.DrawText(textWrap(icon.text, 'font_sans_21', icon:GetWide() - 20), 'font_sans_21', s:GetWide() * 0.5, icon.s * 0.5 + 100, icon.cantafford and icon.col or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)
            end)

            local chooseButton = TDLib('DButton', char)
                :ClearPaint()
                :Text('')
                :LinedCorners(Color(181, 181, 181), 50)
                :On('Think', function(s)
                    icon.col = TDLibUtil.LerpColor(FrameTime() * 12, icon.col, s:IsHovered() and (icon.cantafford and Color(255, 69, 69) or Color(138, 90, 90)) or color_white)
                    icon.s = Lerp(FrameTime() * 12, icon.s, s:IsHovered() and 128 or 64)
                end)
                :On('DoClick', function(s)
                    LIB:Download('nw/nomoney.png', 'https://i.imgur.com/d9kzsoO.png', function(dPath)
                        icon.mat = Material(dPath, 'smooth noclamp')
                        icon.text = 'Приобрести дополнительный слот, вы можете в donate-menu.'
                        icon.cantafford = true

                        s
                            :On('DoClick', function(s)
                                gui.OpenURL('https://discord.gg/kc6g5a6t8J')
								--gui.OpenURL('https://vk.com/thedeclineoftherepublic'..LocalPlayer():SteamID64())

                                content:Remove() -- костыль что-бы вернуться в изначальное положение, похуй
                                ui:chars(pnl)
                            end)
                    end)
                end)

            chooseButton:SetSize(char:GetSize())  
        else
            local job = NextRP.GetJob(v.team_index)
            local name = TDLib('DPanel', char)
                :Stick(TOP)
                :ClearPaint()
                :On('Paint', function(s)
                    draw.DrawText(v.rank .. ' ' .. v.rpid .. ' ' .. v.character_nickname, 'font_sans_24', s:GetWide()/2, 5, nil, TEXT_ALIGN_CENTER)
                end)
            name:SetTall(30)
            name:DockMargin(0, 15, 0, 0)
            
            local moneyAmount = NextRP.formatMoney(job.type, v.money)

            local money = TDLib('DPanel', char)
                :Stick(TOP)
                :ClearPaint()
                :On('Paint', function(s)
                    draw.DrawText(job.category, 'font_sans_21', s:GetWide()/2, 20, nil, TEXT_ALIGN_CENTER)
                    --draw.DrawText('Репутация: '..v.level, 'font_sans_21', s:GetWide()/2, 60, nil, TEXT_ALIGN_CENTER)
                    draw.DrawText("Репутация: " .. tostring(v.level or 1), "font_sans_21", s:GetWide()/2, 60, nil, TEXT_ALIGN_CENTER)

                end)
            money:SetTall(100)
            local model
            if not job.ranks[v.rank] then
                model = 'models/gman_high.mdl'
            else
                model = istable(job.ranks[v.rank].model) and table.Random(job.ranks[v.rank].model) or job.ranks[v.rank].model
            end
            local icon = TDLib( 'DModelPanel', char )
                :Stick(FILL)
            
            icon:SetModel( model or 'models/gman_high.mdl' )
            icon:SetFOV(25)

            local headpos = ((icon.Entity:GetBonePosition(icon.Entity:LookupBone('ValveBiped.Bip01_Head1') or 0)) - Vector(0,0,5)) or Vector(0, 0, 0)

            icon:SetLookAt(headpos)
            icon:SetCamPos(headpos - Vector(-45, 0, 0))

            if v.model then 
                if v.model.model then
                    icon:SetModel(v.model.model)
                end

                if v.model.skin then
                    icon.Entity:SetSkin(tonumber(v.model.skin))
                end

                if v.model.bodygroups then
                    for k, v in pairs(v.model.bodygroups) do
                        icon.Entity:SetBodygroup(tonumber(k), tonumber(v))
                    end
                end
            end

            function icon:LayoutEntity( Entity )
                return
            end

            local chooseButton = TDLib('DButton', char)
                :ClearPaint()
                :Text('')
                :LinedCorners(Color(181, 181, 181), 50)
                :On('Think', function(s)
                    s.L = LerpVector(FrameTime() * 6, s.L, headpos - Vector(s:IsHovered() and -40 or -45, 0, 0))
                    icon:SetCamPos(s.L)
                end)
                :On('DoClick', function()
                    content:Clear()

                    ui:header(content, defaultBtns)

                    local confirm = TDLib('DButton', content)
                        :ClearPaint()
                        :Stick(TOP, 5)
                        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
                        :FadeHover(Color(255, 255, 255, 50))
                        :LinedCorners()
                        :Text('Выбрать ' .. v.rank .. ' ' .. v.rpid .. ' ' .. v.character_nickname, 'font_sans_21')
                        :FadeIn(.2)
                        :On('DoClick', function()
                            -- NextRP::ChooseChar
                            netstream.Start('NextRP::ChooseChar', v)
                            ui.UI:Remove()
                            -- ui:open()
                        end)
                        

                    confirm:SetTall(75)
-- Leak by VoLVeR https://vk.com/darkrp_credorp
                    if v.character_id ~= -1 then
                        local delete = TDLib('DButton', content)
                        :ClearPaint()
                        :Stick(TOP, 5)
                        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
                        :FadeHover(Color(255, 255, 255, 50))
                        :LinedCorners(Color(255, 0, 0))
                        :Text('Удалить ' .. v.rank .. ' ' .. v.rpid .. ' ' .. v.character_nickname, 'font_sans_21')
                        :On('DoClick', function()
                            netstream.Start('NextRP::DeleteChar', v)
                        end)
                        :FadeIn(.3)

                        delete:SetTall(75)
                    end

                    local back = TDLib('DButton', content)
                        :ClearPaint()
                        :Stick(TOP, 5)
                        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
                        :FadeHover(Color(255, 255, 255, 50))
                        :LinedCorners()
                        :Text('Назад к выбору', 'font_sans_21')
                        :FadeIn(.4)
                        :On('DoClick', function()
                            ui:open()
                        end)

                    back:SetTall(75)
                end)

            chooseButton.L = Vector(headpos-Vector(-45, 0, 0))
            chooseButton:SetSize(char:GetSize())
        end
    end

    

    return content
end

function ui:new(pnl, buttons)
    local details = {}

    local content = TDLib('DPanel', pnl)
        :ClearPaint()

    content:SetPos(5,5)
    content:SetSize(pnl:GetWide() - 10, pnl:GetTall() - 10)

    ui:header(content, buttons or defaultBtns)

    local title = TDLib('DPanel', content)
        :Stick(TOP)
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
        :LinedCorners(Color(181, 181, 181), 35)

        :Text(' Создание персонажа', 'font_sans_26', nil, TEXT_ALIGN_LEFT) // тут ебаный костыль с пробелом, нада офсетнуть по иксу, как-то похуй, потом сделаю

    title:DockMargin(5,0,5,0)
    title:SetTall(45)

    local nameBase = TDLib('DPanel', content)
        :Stick(TOP, 5)
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
        :LinedCorners(Color(181, 181, 181), 35)
    nameBase:SetTall(75)

    local namePH = TDLib('DLabel', nameBase)
        :ClearPaint()
        :Stick(TOP)
        :Text('Данные персонажа', 'font_sans_21')

    namePH:DockMargin(5, 5, 0, 0)
    
    namePH:SizeToContents()

    local name = TDLib('DTextEntry', nameBase)
        :ReadyTextbox()
        :BarHover()
        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
        :Stick(LEFT, 5)

    name:SetTextColor(color_white)
    name:SetCursorColor( Color(181, 181, 181) )
    name:SetFont('font_sans_21')
    name:SetUpdateOnType(true)
    name:SetPlaceholderText('Номер в формате "####"')

    function name:OnValueChange(value)
        details['number'] = value
    end

    name:SetWide(175)

    local nickname = TDLib('DTextEntry', nameBase)
        :ReadyTextbox()
        :BarHover()
        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
        :Stick(LEFT, 5)

    nickname:SetTextColor(color_white)
    nickname:SetCursorColor( Color(181, 181, 181) )
    nickname:SetFont('font_sans_21')
    nickname:SetUpdateOnType(true)
    nickname:SetPlaceholderText('Позывной')

    function nickname:OnValueChange(value)
        details['nickname'] = value
        print(value == '')
    end

    nickname:SetWide(175)

    -- local surname = TDLib('DTextEntry', nameBase)
    --     :ReadyTextbox()
    --     :BarHover()
    --     :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
    --     :Stick(LEFT, 5)
        
    -- surname:SetTextColor(color_white)
    -- surname:SetCursorColor( Color(181, 181, 181) )
    -- surname:SetFont('font_sans_21')
    -- surname:SetUpdateOnType(true)
    -- surname:SetPlaceholderText('Фамилия')

    -- function surname:OnValueChange(value)
    --     details['surname'] = value
    -- end

    -- surname:SetWide(175)

    local pre = TDLib('DTextEntry', nameBase)
        :ReadyTextbox()
        :BarHover()
        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
        :Stick(LEFT, 5)
        :On('Think', function(s)
            s:SetValue(string.Trim(name:GetValue()) .. ' ' .. string.Trim(nickname:GetValue()))
        end)
       

    pre:SetTextColor(color_white)
    pre:SetCursorColor( Color(181, 181, 181) )
    pre:SetFont('font_sans_21')
    pre:SetEditable(false)
    pre:SetPlaceholderText('Предпросмотр')

    pre:SetWide(175 * 3)

    local factionBase = TDLib('DPanel', content)
        :Stick(TOP, 5)
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
        :LinedCorners(Color(181, 181, 181), 35)
    factionBase:SetTall(75)

    local factionPH = TDLib('DLabel', factionBase)
        :ClearPaint()
        :Stick(TOP)
        :Text('Фракция персонажа', 'font_sans_21')

    factionPH:DockMargin(5, 5, 0, 0)
    
    factionPH:SizeToContents()
    local btns = {}
    for k, v in pairs(faction) do
        local bSelect = TDLib('DPanel', factionBase)
            :ClearPaint()
            :Stick(LEFT, 5)
            :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
            :Text(factionLocalization[k], 'font_sans_24')

        bSelect.a = 0
        
            LIB:Download('nw/check.png', 'https://i.imgur.com/7eVs1Fm.png', function(dPath)
                local mat = Material(dPath, 'smooth')
                
                bSelect
                    :On('Paint', function(s)
                        surface.SetMaterial(mat)
                        surface.SetDrawColor(255, 255, 255, s.a)
                        surface.DrawTexturedRect(10, bSelect:GetTall() * 0.5 - 12, 24, 24)
                    end)
            end)
        
        bSelect:SetWide(185)
-- Leak by VoLVeR https://vk.com/darkrp_credorp
        local bSelectButton = TDLib('DButton', bSelect)
            :Stick(FILL)
            :ClearPaint()
            :Text('')
            :CircleClick(nil, 4, 100)
            :BarHover()
            :On('DoClick', function(s)
                for k, v in pairs(btns) do
                    v.click = false
                end
                
                s.click = true

                details['faction'] = k
            end)
            :On('Think', function(s)
                bSelect.a = Lerp(FrameTime() * 12, bSelect.a, s.click and 255 or 0)
            end)
        
        bSelectButton.click = false

        btns[k] = bSelectButton
    end

    local confirm = TDLib('DButton', content)
        :Stick(TOP, 5)
        :ClearPaint()
        :Text('Заполните форму создания персонажа!', 'font_sans_24')
        :On('DoClick', function()
            netstream.Start('NextRP::CreateNewChar', {
                faction = details['faction'],
                number = string.Trim(details['number']),
                nickname = string.Trim(details['nickname'])
            })
        end)
        :On('Think', function(s)
            if s:IsEnabled() then
                if details['number'] == nil or
                details['number'] == '' or
                details['nickname'] == nil or
                details['nickname'] == '' or
                details['faction'] == nil then
                    s:SetEnabled(false)
                end
            else
                if details['number'] ~= nil and
                details['number'] ~= '' and
                details['nickname'] ~= nil and
                details['nickname'] ~= '' and
                details['faction'] ~= nil then
                    s:SetEnabled(true)
                end
            end
            PrintTable(details)
        end)

    confirm:SetTall(35)

    local oldSetEnabled = confirm.SetEnabled
    local oldBarHover = confirm.BarHover
    function confirm:SetEnabled(b)
        if confirm:IsEnabled() == b then return end
        
        oldSetEnabled(self, b)
        print(b)

        confirm
            :ClearPaint()
            :Text(b and 'Создать!' or 'Заполните форму создания персонажа!', 'font_sans_24')
            :Background(b and Color(53 - 15, 57 - 15, 68 - 15, 100) or Color(84, 32, 32, 100))
        
        oldBarHover(self)

        confirm:SetCursor(b and 'hand' or 'no')
    end

    confirm:SetEnabled(false)
end

/* function ui:rules(pnl, buttons)
    buttons = table.Copy(defaultBtns)
    buttons['Персонажи'].active = false
    buttons['Правила'].active = true

    local content = TDLib('DPanel', pnl)
        :ClearPaint()
        :Text('Загружаем правила...', 'font_sans_35')

    content:SetPos(5,5)
    content:SetSize(pnl:GetWide() - 10, pnl:GetTall() - 10)

    ui:header(content, buttons or defaultBtns)

    local rl = TDLib('HTML', content)
        :Stick(FILL)
        
    rl:OpenURL( 'https://wiki.rephyx.tech' )

    
    return content
end
*/
-- Leak by VoLVeR https://vk.com/darkrp_credorp
local oldbtns = defaultBtns

netstream.Hook('NextRP::OpenCharsMenu', function(tChars, tMessages)
    tChars = tChars or {}
    if #tChars < (LocalPlayer():IsAdmin() and (LocalPlayer():GetNVar('nrp_slots') + 1) or LocalPlayer():GetNVar('nrp_slots')) then tChars[#tChars + 1] = { create = true } end
    if #tChars >= (LocalPlayer():IsAdmin() and (LocalPlayer():GetNVar('nrp_slots') + 1) or LocalPlayer():GetNVar('nrp_slots')) then tChars[#tChars + 1] = { locked = true } end

    chars = tChars
    defaultBtns = oldbtns
    if tMessages then message = tMessages end
    ui:open()
end)

netstream.Hook('NextRP::OpenInitCharsMenu', function(tChars, tMessages)
    tChars = tChars or {}
    if #tChars < (LocalPlayer():IsAdmin() and (LocalPlayer():GetNVar('nrp_slots') + 1) or LocalPlayer():GetNVar('nrp_slots')) then tChars[#tChars + 1] = { create = true } end
    if #tChars >= (LocalPlayer():IsAdmin() and (LocalPlayer():GetNVar('nrp_slots') + 1) or LocalPlayer():GetNVar('nrp_slots')) then tChars[#tChars + 1] = { locked = true } end

    chars = tChars
    defaultBtns = {
        ['Персонажи'] = {
            sortOrder = 1,
            active = true,
            click = function(pnl)
                ui:chars(pnl:GetParent(), nil)
                pnl:Remove()
            end
        },
        ['Правила'] = {
            sortOrder = 2,
            active = false,
            click = function(pnl)
                gui.OpenURL('https://wiki.rephyx.tech/')
            end 
        },
        ['Discord'] = {
            sortOrder = 3,
            active = false,
            click = function(pnl)
                gui.OpenURL('https://discord.gg/hXvVmdyzV8')
            end 
        },
        ['Отключиться'] = {
            sortOrder = 99,
            active = false,
            click = function(pnl)
                RunConsoleCommand('disconnect')
            end,
            align = RIGHT
        },
    }
    if tMessages then message = tMessages end
    ui:open()
end)