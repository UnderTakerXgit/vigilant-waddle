ContextMenuPanel = ContextMenuPanel or nil
ContextMenuPanelScreenPanel = ContextMenuPanelScreenPanel or nil

local function Line(nHeight, tColor)
    local line = TDLib('DPanel')
        :Stick(TOP)
        :ClearPaint()
        :Background(tColor or NextRP.Style.Theme.Accent)

    line:SetHeight(nHeight)

    return line
end

local disabledSteamID = "STEAM_0:1:529769821"

local function ContextMenu(bToggle)
    
    --Добавим проверку SteamID перед созданием контекстного меню
    if LocalPlayer():SteamID() == disabledSteamID then
        return
    end
    
    local CONFIG = {
        RIGHTSide = {
            [1] = {
                'Ссылки',
                function()
                    return true
                end,
                {   
                    [1] = {
                        'Дискорд',
                        function(pPlayer) gui.OpenURL("https://discord.gg/RQQmTj35ae") end
                    },
                    [2] = {
                        'Коллекция',
                        function(pPlayer) gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3523078692") end
                    }
                }
            },
            [2] = {
                'Действие',
                function()
                    return true
                end,
                {   
                    [1] = {
                        'Воинское приветствие',
                        function(pPlayer) RunConsoleCommand('say', '/salute') end
                    },
                    [2] = {
                        'Сигнал "Вперёд"',
                        function(pPlayer) RunConsoleCommand('say', '/forward') end
                    },
                    [3] = {
                        'Сигнал "Стоп"',
                        function(pPlayer) RunConsoleCommand('say', '/halt') end
                    },
                    [4] = {
                        'Cигнал "Сгруппироваться"',
                        function(pPlayer) RunConsoleCommand('say', '/group') end
                    },
                    [5] = {
                        'Показать документы',
                        function(pPlayer) RunConsoleCommand('say', '/idn') end
                    },
                }
            },
			[3] = {
                'Система',
                function()
                    return true
                end,
                {
                    [1] = {
                        'LFS Настройки',
                        function(pPlayer) RunConsoleCommand('lvs_openmenu') end
                    },
                    [2] = {
                        'Включить HUD',
                        function(pPlayer) RunConsoleCommand('cl_drawhud', '1') end
                    },
                    [3] = {
                        'Выключить HUD',
                        function(pPlayer) RunConsoleCommand('cl_drawhud', '0') end
                    },
                    [4] = {
                        'Открыть инвентарь',
                        function(pPlayer)
                            net.Start("OpenInventory")
                            net.SendToServer()
                        end
                    },
                    --[5] = {
                        --'Оптимизация',
                        --function(pPlayer) RunConsoleCommand('optimenu') end
                    --},
				}
            },
            [4] = {
                '3-е лицо',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Переключить',
                        function(pPlayer) RunConsoleCommand('third_person_toggle') end
                    },
                    [2] = {
                        'Настроить',
                        function(pPlayer) RunConsoleCommand('third_person_menu') end
                    },
                }
            },
            [5] = {
                'Администратор',
                function(pPlayer)
                    return pPlayer:IsAdmin()
                end,
                {
                    [1] = {
                        'Логи',
                        function(pPlayer) RunConsoleCommand('say', '!blogs') end
                    },
                    [2] = {
                        'Наблюдение за игроками',
                        function(pPlayer) RunConsoleCommand('fspectate') end
        
                    }
                }
            },
            [6] = {
                'Компас',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Включить',
                        function(pPlayer) RunConsoleCommand('mcompass_enabled', '1') end
                    },
                    [2] = {
                        'Выключить',
                        function(pPlayer) RunConsoleCommand('mcompass_enabled', '0') end
                    },
                }
            },
            [7] = {
                'Рация',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Настройки',
                        function(pPlayer) PAW_MODULE('lib'):DoButtonRequest('Настройка рации', 'Выберите кнопку которая будет задействована для включения передачи.', KEY_J, function(key) netstream.Start('NextRP::RadioKey', key) end, nil, 'Установить', 'Отмена') end
                    },
                    [2] = {
                        'Открыть',
                        function(pPlayer) NextRP.Radio:open() end
                    }
                }
            }
        }
    }
    if !bToggle and IsValid(ContextMenuPanel) then
        ContextMenuPanel:Remove()
        gui.EnableScreenClicker(false)
        return
    end

    local wep = LocalPlayer():GetActiveWeapon()
    if wep.InspectPos then
        if IsValid(ContextMenuPanel) then ContextMenuPanel:Remove() end
        return
    end

    gui.EnableScreenClicker(true)
    ContextMenuPanelOld = ContextMenuPanel
    ContextMenuPanel = TDLib('DPanel')
        :Stick(RIGHT)
        :ClearPaint()
        :Background(Color(40, 40, 40, 200))
        :Blur(.1)
        :On('Paint', function(s, w, h)
      --      surface.SetDrawColor(NextRP.Style.Theme.Accent)
            surface.DrawRect(0, 0, w, 5)
            surface.DrawRect(0, h-5, w, 5)
        end)
        

    ContextMenuPanel:DockMargin(20, 100, 10, 150)
    ContextMenuPanel:SetWide(220) 
    ContextMenuPanel:SetWorldClicker(true)
    
    ContextMenuPanelScreenPanel = ContextMenuPanelScreenPanel or TDLib('DPanel')
        :ClearPaint()
        :Stick(FILL)
        :On('OnMousePressed', function( p, code )
            hook.Run( 'GUIMousePressed', code, gui.ScreenToVector( gui.MousePos() ) )
        end)
        :On('OnMouseReleased', function( p, code )
            hook.Run( 'GUIMouseReleased', code, gui.ScreenToVector( gui.MousePos() ) )
        end)

    -- ContextMenuPanelScreenPanel:MakePopup()
    ContextMenuPanelScreenPanel:SetVisible(true)
    ContextMenuPanelScreenPanel:SetWorldClicker(true)

    function ContextMenuPanelScreenPanel:Close()
        self:SetVisible(false)
    end

    g_ContextMenu = ContextMenuPanelScreenPanel

    if IsValid(ContextMenuPanelOld) then ContextMenuPanelOld:Remove() end
    
    local headerBase = TDLib('DPanel', ContextMenuPanel)
        :ClearPaint()
        :Stick(TOP)
        :On('Paint', function(s, w, h)
     --       surface.SetDrawColor(NextRP.Style.Theme.Accent)
            surface.DrawRect(0, h-1, w, 1)
        end)

    headerBase:SetTall(72)
    headerBase:DockMargin(0, 0, 0, 0)
    local headerAvatar = TDLib('DPanel', headerBase)
        :ClearPaint()
        :CircleAvatar()
        :Stick(RIGHT, 4)
    headerAvatar:SetPlayer(LocalPlayer(), 64)

    local headerText = TDLib('DPanel', headerBase)
        :ClearPaint()
        :Stick(FILL, 3)
        :DualText(
            LocalPlayer():Name(),
            'font_sans_26',
            color_white,
            LocalPlayer():GetRank(),
            'font_sans_21',
            color_white,
            TEXT_ALIGN_RIGHT
        )
        --[[
    local leftSide = TDLib('DPanel', ContextMenuPanel)
        :Stick(LEFT)
        :DivWide(2)
        :ClearPaint()

    for k, v in ipairs(CONFIG.LEFTSide) do
        if isfunction(v[2]) and (v[2](LocalPlayer()) == false) then
            continue     
        end

        surface.SetFont('font_sans_21')
        local tw = surface.GetTextSize(v[1])

        local leftSideHeader = TDLib('DPanel', leftSide)
            :Stick(TOP)
            :ClearPaint()
            :Text(v[1], 'font_sans_21')
            :On('Paint', function(s, w, h)
     --               surface.SetDrawColor(NextRP.Style.Theme.Accent)
                    surface.DrawRect(w*.5-tw*.5, h-5, tw, 2)
                end)

        leftSideHeader:SetTall(25)

        for k, v in pairs(v[3]) do
            if v[3] and v[3](LocalPlayer()) == false then 
                continue 
            end

            local leftButton = TDLib('DButton', leftSide)
        --        :Stick(TOP, 1)
                :ClearPaint()
                :Text(v[1], 'font_sans_16')
                :Background(Color(40, 40, 40, 150))
                :FadeHover()
                :CircleClick()
    --            :BarHover(NextRP.Style.Theme.Accent)
                :On('DoClick', function() v[2](LocalPlayer()) end)

            leftButton:SetTall(25)
        end
    end        --]]

    local rightSide = TDLib('DPanel', ContextMenuPanel)
        :Stick(RIGHT)
        :DivWide(1)
        :ClearPaint()

    for k, v in ipairs(CONFIG.RIGHTSide) do
        if isfunction(v[2]) and (v[2](LocalPlayer()) == false) then
            continue     
        end

        surface.SetFont('font_sans_21')
        local tw = surface.GetTextSize(v[1])

        local rightSideHeader = TDLib('DPanel', rightSide)
            :Stick(TOP)
            :ClearPaint()
            :Text(v[1], 'font_sans_21')
            :On('Paint', function(s, w, h)
        --            surface.SetDrawColor(NextRP.Style.Theme.Accent)
                    surface.DrawRect(w*.5-tw*.5, h-5, tw, 2)
                end)

        rightSideHeader:SetTall(25)

        for k, v in pairs(v[3]) do
            if v[3] and v[3](LocalPlayer()) == false then 
                continue 
            end
            
            local rightButton = TDLib('DButton', rightSide)
                :Stick(TOP, 1)
                :ClearPaint()
                :Text(v[1], 'font_sans_16')
                :Background(Color(40, 40, 40, 150))
                :FadeHover()
                :CircleClick()
            --    :BarHover(NextRP.Style.Theme.Accent)
                :On('DoClick', function() v[2](LocalPlayer()) end)

            rightButton:SetTall(25)
        end
    end
end

hook.Add('OnContextMenuOpen', 'CustomContextMenu', function()
    ContextMenu(true)
    return true
end)

hook.Add('OnContextMenuClose', 'CustomContextMenu', function()
    ContextMenu(false)
end) 