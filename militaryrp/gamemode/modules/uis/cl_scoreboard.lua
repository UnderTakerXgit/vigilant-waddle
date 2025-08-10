local LIB = PAW_MODULE('lib')
-- Leak by VoLVeR https://vk.com/darkrp_credorp
local W = ScrW
local H = ScrH

local scoreboard = NextRP.Scoreboard

scoreboard.Base = scoreboardBase
scoreboard.Blur = scoreboardBlur

function scoreboard:AddPlayer(pPlayer)
    local Panel = TDLib('DPanel')
        :Stick(TOP)
        :ClearPaint()
        :Background(Color(60, 60, 60, 200))

    Panel:DockMargin(0, 2, 0, 0)
    Panel:SetTall(35)

    local namePlace = TDLib('DPanel', Panel)
            :Stick(LEFT)
            :DivWide(4)
            :ClearPaint()


    local AvatarCircle = TDLib('DPanel', namePlace)
        :Stick(LEFT, 3)
        :SquareFromHeight()
        :ClearPaint()
        :Circle(team.GetColor(pPlayer:Team()))

    local Avatar = TDLib('DPanel', AvatarCircle)
        :Stick(FILL, 1)
        :SquareFromHeight()
        :CircleAvatar()
        :SetPlayer(pPlayer, 184)

    local DisplayName = TDLib('DPanel', namePlace)
        :Stick(FILL)
        :ClearPaint()
        :Text(pPlayer:FullName(), 'font_sans_21', nil, TEXT_ALIGN_LEFT, 3)      
    
    local spec = pPlayer:GetNVar('nrp_charflags') or {}
	local jt = pPlayer:getJobTable()

	local final = 'Без специализации'
	for k, v in pairs(spec) do
		if not istable(final) then final = {} end
		final[#final + 1] = jt.flags[k].id
	end

	if istable(final) then
		final = table.concat(final, ', ')
	end
    local ActionsButton = TDLib('DButton', Panel)
        :ClearPaint()
        :CircleClick()
        :Text('')
        :On('DoClick', function(s)
            surface.PlaySound( 'gmodadminsuite/btn_heavy.ogg' )
            local Menu = vgui.Create('Paws.Menu')

            local CopySteamID = Menu:AddOption('Скопировать SteamID', function() SetClipboardText( pPlayer:SteamID() ) surface.PlaySound('gmodadminsuite/success.ogg') end):SetIcon('gmodadminsuite/steam.png')

            if LocalPlayer():IsAdmin() then
            
                local AdminActions, Parent = Menu:AddSubMenu( 'Админ меню', function() RunConsoleCommand('ulx', 'menu') scoreboard:ScoreboardToggle(false) end)
                Parent:SetIcon('icon16/database.png')

                local InfoActions, Parent = AdminActions:AddSubMenu( 'Информация о '..pPlayer:Nick(), function() RunConsoleCommand('ulx', 'menu') scoreboard:ScoreboardToggle(false) end)
                InfoActions:AddOption('Звание: '..pPlayer:GetRank(), function() SetClipboardText( pPlayer:GetRank() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                --InfoActions:AddOption('Номер: '..PlayerNumber, function() SetClipboardText( PlayerNumber ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                InfoActions:AddOption('Имя: '..pPlayer:Name(), function() SetClipboardText( pPlayer:Name() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                InfoActions:AddOption('Позывной: '..pPlayer:Nick1(), function() SetClipboardText( pPlayer:Nick1() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                --InfoActions:AddOption('Фамилия: '..pPlayer:Surname(), function() SetClipboardText( pPlayer:Surname() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                InfoActions:AddOption('Рация включена: '..(pPlayer:GetNVar('radio_speaker') and 'Включена' or 'Выключена'), function() SetClipboardText( (pPlayer:GetNVar('radio_speaker') and 'Включена' or 'Выключена') ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                InfoActions:AddOption('Частота рации: ' .. (pPlayer:GetNVar('radio_frequency') or 'Неизвестно'), function() SetClipboardText( pPlayer:GetNVar('radio_frequency') or 'Неизвестно' ) surface.PlaySound('gmodadminsuite/success.ogg') end)

                Parent:SetIcon('icon16/disk_multiple.png')

                AdminActions:AddOption('ТП к '..pPlayer:Nick(), function() RunConsoleCommand('sa', 'goto', pPlayer:Nick1()) end):SetIcon('icon16/world_go.png')
                AdminActions:AddOption('ТП '..pPlayer:Nick()..' к себе', function() RunConsoleCommand('sa', 'bring', pPlayer:Nick1()) end):SetIcon('icon16/world_go.png')
                AdminActions:AddOption('Кикнуть '..pPlayer:Nick(), function() LIB:DoStringRequest('Кик', 'Введите причину для кика игрока '..pPlayer:Nick1(), '', function(str) RunConsoleCommand('sa', 'kickr', pPlayer:Nick(), str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Кикнуть!', 'Отмена') end):SetIcon('icon16/disconnect.png')

                local BanActions, Parent = AdminActions:AddSubMenu( 'Забанить '..pPlayer:FullName(), function() RunConsoleCommand('ulx', 'menu') scoreboard:ScoreboardToggle(false) end)
                Parent:SetIcon('icon16/disconnect.png')

                BanActions:AddOption('На 10 минут', function() LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick1()..' на 10 минут.', '', function(str) RunConsoleCommand('sa', 'banid', pPlayer:SteamID(), '10', str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Забанить!', 'Отмена') end):SetIcon('icon16/accept.png')
                BanActions:AddOption('На 30 минут', function() LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick1()..' на 30 минут.', '', function(str) RunConsoleCommand('sa', 'banid', pPlayer:SteamID(), '30', str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Забанить!', 'Отмена') end):SetIcon('icon16/accept.png')
                BanActions:AddOption('На 60 минут', function() LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick1()..' на 60 минут.', '', function(str) RunConsoleCommand('sa', 'banid', pPlayer:SteamID(), '60', str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Забанить!', 'Отмена') end):SetIcon('icon16/accept.png')
                BanActions:AddOption('Указать время', function()
                    LIB:DoStringRequest('Бан', 'Введите время бана для '..pPlayer:Nick()..' в минутах.', '', function(BanL)
                        // RunConsoleCommand('sa', 'banid', pPlayer:Nick(), '60', str)
                        LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick()..' на '..BanL..' минут(ы).', '', function(BanR)
                            RunConsoleCommand('sa', 'banid', pPlayer:SteamID(), BanL, BanR)
                            surface.PlaySound('gmodadminsuite/success.ogg')
                        end, nil, 'Забанить!', 'Отмена')
                    end, nil, 'Далее!', 'Отмена')
                end)
            end

            local PropertiesOpen = Menu:AddOption('CMenu', function()
                timer.Simple(.1, function() properties.OpenEntityMenu( pPlayer, LocalPlayer():GetEyeTrace() ) end)
            end):SetIcon('icon16/cog_go.png')

            Menu:Open()
        end)
        :On('DoRightClick', function(s)
            properties.OpenEntityMenu( pPlayer, LocalPlayer():GetEyeTrace() )
        end)

    ActionsButton:SetSize(Panel:GetWide(), Panel:GetTall())

    return Panel
end
-- Leak by VoLVeR https://vk.com/darkrp_credorp
function scoreboard:ScoreboardToggle(bToggle)
    if bToggle then
        scoreboardBlur = TDLib('DPanel')
            :Stick(FILL)
            :ClearPaint()
            :Blur()
            :FadeIn()

        scoreboardBase = TDLib('DPanel')
            :ClearPaint()
            :Background(Color(53, 57, 68, 200))
            :FadeIn()
            :Stick(FILL)

        local base = scoreboardBase
        scoreboard.Base = base
        scoreboard.Blur = scoreboardBlur

        base:MakePopup()

        local title = TDLib('DPanel', base)
            :Stick(TOP, 5)
            :ClearPaint()
            :DualText(
                'Rephyx.tech | UmbrellaRP',
                'font_sans_35',
                Color(255, 255, 255, 255),

                'Umbrella Containment Zone | Игроков '..#player.GetAll()..'/'..game.MaxPlayers(),
                'font_sans_21',
                Color(150, 150, 150, 200),
                TEXT_ALIGN_LEFT
            )

        title:SetTall(65)

        local line = TDLib('DPanel', base)
            :Stick(TOP, 5)
            :ClearPaint()
            :Background(Color(53, 57, 68))

        line:SetTall(5)

        local subheader = TDLib('DPanel', base)
            :Stick(TOP)
            :ClearPaint()

        local scrollPanel = TDLib('DScrollPanel', base)
            :Stick(FILL, 5)

        local scrollPanelBar = scrollPanel:GetVBar()
        scrollPanelBar:TDLib()
            :ClearPaint()
            :Background(Color(53, 57, 68, 50))

        scrollPanelBar.btnUp:TDLib()
            :ClearPaint()
            :Background(Color(53, 57, 68))
            :CircleClick()

        scrollPanelBar.btnDown:TDLib()
            :ClearPaint()
            :Background(Color(53, 57, 68))
            :CircleClick()

        scrollPanelBar.btnGrip:TDLib()
            :ClearPaint()
            :Background(Color(53, 57, 68))
            :CircleClick()

        for k, category in pairs(NextRP.Categories) do
            local shouldDelete = true

            local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
                :Stick(TOP, 2)
                :ClearPaint()
                :On('OnToggle', function(self) 
                
                    if self:GetExpanded() then
                        self.Header:TDLib()
                            :ClearPaint()
                            :Background(Color(40, 40, 40, 200))
                    else
                        self.Header:TDLib()
                            :ClearPaint()
                            :Background(Color(60, 60, 60, 200))
                    end
            
                end)

            DCategory.Header:TDLib()
                :ClearPaint()
                :Text(category.name, 'font_sans_24')

            if DCategory:GetExpanded() then
                DCategory.Header:TDLib():Background(Color(40, 40, 40, 200))
            else
                DCategory.Header:TDLib():Background(Color(60, 60, 60, 200))
            end

            DCategory.Header:SetTall(35)

            local contents = vgui.Create('DPanelList', DCategory)

            contents:SetPadding(0)
            contents:SetSpacing(4)
            DCategory:SetContents(contents)

            for k, member in pairs(category.members) do
            
                if team.NumPlayers(member.index) <= 0 then continue end
                shouldDelete = false
                
                for k, pl in pairs(team.GetPlayers(member.index)) do
                    
                    if IsValid(pl) and pl:GetNVar('is_load_char') then
                        contents:Add(scoreboard:AddPlayer(pl))
                    end
                end
            end

            if shouldDelete then DCategory:Remove() end
        end
        
    else
        if IsValid(scoreboard.Base) then
            scoreboard.Base:TDLib():FadeOut()
            scoreboard.Blur:TDLib():FadeOut()
            timer.Simple(.1, function() scoreboard.Base:Remove() scoreboard.Blur:Remove() end)
        end
    end
end

hook.Add('ScoreboardShow', 'Paws.Scoreboard.Show', function()
    scoreboard:ScoreboardToggle(true)
    return false
end)

hook.Add('ScoreboardHide', 'Paws.Scoreboard.Show', function()
    scoreboard:ScoreboardToggle(false)
end)