local ranks = NextRP.Ranks
local ui = {UI = nil}
ranks.ui = ui

local LIB = PAW_MODULE('lib')

function ui:open(pTarget)
    if IsValid(ui.UI) then ui.UI:Remove() end

    ui.UI = TDLib('DPanel')
        :ClearPaint()
        :Background(Color(53, 57, 68), 3)
    ui.UI:SetSize(300, 215)
    ui.UI:Center()
    ui.UI:MakePopup()
    
    local Title = TDLib('DPanel', ui.UI)
        :Stick(TOP, 5)
        :ClearPaint()
        :On('Paint', function(s, w, h)
            draw.DrawText('Управление персонажем\n'..pTarget:FullName()..'\nID: '..pTarget:GetNVar('nrp_charid'), 'font_sans_16', w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)
        end)
    Title:SetTall(45)

    local NamesButton = TDLib('DButton', ui.UI)
        :Stick(TOP, 5)
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
        :Text('Управление именем', 'font_sans_16')
        :CircleClick(nil, 5, 35)
        :On('DoClick', function()
            local m = vgui.Create('Paws.Menu')
            m:AddOption('Изменить номер', function()
                LIB:DoStringRequest('Изменение номера', 'Введите номер который нужно установить', pTarget:GetNVar('nrp_rpid'), function(v)
                    netstream.Start('NextRP::SetCharNumber', pTarget, v)
                end, nil, 'Подтвердить', 'Отмена')
            end)
            m:AddOption('Изменить позывной', function()
                LIB:DoStringRequest('Изменение позывного', 'Введите позывной который нужно установить', pTarget:GetNickname(), function(v)
                    netstream.Start('NextRP::SetCharNickname', pTarget, v)
                end, nil, 'Подтвердить', 'Отмена')
            end)

            m:SetPos(gui.MousePos())
            m:Open()
        end)

    local RanksButton = TDLib('DButton', ui.UI)
        :Stick(TOP, 5) 
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
        :Text('Управление званием', 'font_sans_16')
        :CircleClick(nil, 5, 35)
        :On('DoClick', function()
            local m = vgui.Create('Paws.Menu')
            
            local jt = pTarget:getJobTable()

            for k, v in SortedPairsByMemberValue(jt.ranks, 'sortOrder') do
                m:AddOption(k .. ' / ' .. v.fullRank or 'Нет', function()
                    netstream.Start('NextRP::SetCharRank', pTarget, k)
                end)
            end

            m:SetPos(gui.MousePos())
            m:Open()
        end)

    local FlagsButton = TDLib('DButton', ui.UI)
        :Stick(TOP, 5) 
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
        :Text('Управление приписками', 'font_sans_16')
        :CircleClick(nil, 5, 35)
        :On('DoClick', function()
            local m = vgui.Create('Paws.Menu')

            local pM = m:AddSubMenu('Добавить')
            local tM = m:AddSubMenu('Убрать')

            local jt = pTarget:getJobTable()
            local allFlags = jt.flags
            local activeFlags = pTarget:GetNVar('nrp_charflags') or {}

            local addFlags = {}

            for k, v in pairs(allFlags) do
                if activeFlags[k] then continue end
                addFlags[k] = true
            end
            
            for k, v in pairs(addFlags) do
                pM:AddOption(allFlags[k].id, function()
                    netstream.Start('NextRP::AddCharFlag', pTarget, k)
                end)
            end

            for k, v in pairs(activeFlags) do
                tM:AddOption(allFlags[k].id, function()
                    netstream.Start('NextRP::RemoveCharFlag', pTarget, k)
                end)
            end

            m:SetPos(gui.MousePos())
            m:Open()
        end)

    local FormButton = TDLib('DButton', ui.UI)
        :Stick(TOP, 5)
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
        :Text('Управление формой', 'font_sans_16')
        :CircleClick(nil, 5, 35)
        :On('DoClick', function()
            local m = vgui.Create('Paws.Menu')

            local pM = m:AddSubMenu('Постоянная')
            local tM = m:AddSubMenu('Временная')

            if LocalPlayer():IsAdmin() then
                for k, v in NextRP.GetSortedCategories() do
                    local categpM = pM:AddSubMenu(v.name)
                    local categtM = tM:AddSubMenu(v.name)

                    for k, job in ipairs(v.members) do
                        categpM:AddOption(job.name, function()
                            netstream.Start('NextRP::GiveTeam', pTarget, job.index, false)
                        end)
                        categtM:AddOption(job.name, function()
                            netstream.Start('NextRP::GiveTeam', pTarget, job.index, true)
                        end)
                    end
                end
                
                
            else
                local jt = LocalPlayer():getJobTable()
                local isCommander = jt.ranks[LocalPlayer():GetRank()].whitelist or false
                if isCommander then
                    pM:AddOption(jt.name, function()
                        netstream.Start('NextRP::GiveTeam', pTarget, jt.index, false)
                    end)
                    tM:AddOption(jt.name, function()
                        netstream.Start('NextRP::GiveTeam', pTarget, jt.index, true)
                    end)
                end
            end

            m:SetPos(gui.MousePos())
            m:Open()
        end)

    local CloseButton = TDLib('DButton', ui.UI)
        :Stick(TOP, 5)
        :ClearPaint()
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(LIB.Config.Colors.Red)
        :Text('Закрыть', 'font_sans_16')
        :CircleClick(nil, nil, 35)
        :SetRemove(ui.UI)
end

function ranks:OpenUI(pTarget)
    ui:open(pTarget)
end

netstream.Hook('NextRP::OpenSelfRankMenu', function()
    ui:open(LocalPlayer())
end)