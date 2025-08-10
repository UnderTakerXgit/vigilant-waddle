local ranks = NextRP.Ranks or {}

function ranks:SetRank(pPlayer, pTarget, sRank)
    if pTarget:GetNVar('nrp_rank') == sRank then
        return
    end

    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на смену звания...')

    pTarget:SetCharValue('rank', sRank, function()
        local c = pTarget:CharacterByID(charid)
        c.rank = sRank

        pTarget:LoadCharacter(function()
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Звание успешно изменено.')
            hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
        end, charid)
        
    end)
end

netstream.Hook('NextRP::SetCharRank', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:SetRank(pPlayer, pTarget, sRank)
end)

function ranks:SetNumber(pPlayer, pTarget, sRank)
    if pTarget:GetNVar('nrp_rpid') == sRank then
        return
    end

    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на смену номера...')

    pTarget:SetCharValue('rpid', sRank, function()
        local c = pTarget:CharacterByID(charid)
        c.rpid = sRank

        pTarget:LoadCharacter(function()
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Номер успешно изменён.')
            hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
        end, charid)
        
    end)
end

netstream.Hook('NextRP::SetCharNumber', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:SetNumber(pPlayer, pTarget, sRank)
end)

-- function ranks:SetName(pPlayer, pTarget, sName)
--     if pTarget:GetNVar('nrp_name') == sName then return end

--     if not ranks:Can(pPlayer, pTarget) then return end

--     local charid = pTarget:GetNVar('nrp_charid')

--     pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на смену имени.')

--     pTarget:SetCharValue('character_name', sName, function()
--         local c = pTarget:CharacterByID(charid)
--         c.character_name = sName

--         pTarget:LoadCharacter(function()
--             pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Имя успешно изменено.')
--             hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
--         end, charid)
        
--     end)
-- end

-- netstream.Hook('NextRP::SetCharName', function(pPlayer, pTarget, sRank)
--     if not IsValid(pPlayer) then return end
--     if not IsValid(pTarget) then return end
--     if not isstring(sRank) then return end

--     ranks:SetName(pPlayer, pTarget, sRank)
-- end)

-- function ranks:SetSurname(pPlayer, pTarget, sName)
--     if pTarget:GetNVar('nrp_surname') == sName then return end

--     if not ranks:Can(pPlayer, pTarget) then return end

--     local charid = pTarget:GetNVar('nrp_charid')

--     pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на смену фамилии.')

--     pTarget:SetCharValue('character_surname', sName, function()
--         local c = pTarget:CharacterByID(charid)
--         c.character_surname = sName

--         pTarget:LoadCharacter(function()
--             pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Фамилия успешно изменена.')
--             hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
--         end, charid)
        
--     end)
-- end

-- netstream.Hook('NextRP::SetCharSurname', function(pPlayer, pTarget, sRank)
--     if not IsValid(pPlayer) then return end
--     if not IsValid(pTarget) then return end
--     if not isstring(sRank) then return end

--     ranks:SetSurname(pPlayer, pTarget, sRank)
-- end)

function ranks:SetNickname(pPlayer, pTarget, sName)
    if pTarget:GetNVar('nrp_nickname') == sName then return end

    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на смену позывного...')

    pTarget:SetCharValue('character_nickname', sName, function()
        local c = pTarget:CharacterByID(charid)
        c.character_nickname = sName

        pTarget:LoadCharacter(function()
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Позывной успешно измененён.')
            hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
        end, charid)
    end)
end

netstream.Hook('NextRP::SetCharNickname', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:SetNickname(pPlayer, pTarget, sRank)
end)

function ranks:AddFlag(pPlayer, pTarget, sFlag)
    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на добавление приписки...')

    local curFlag = pTarget:GetNVar('nrp_charflags') or {}
    if curFlag[sFlag] then return end
    curFlag[sFlag] = true

    pTarget:SetCharValue('flag', util.TableToJSON(curFlag), function()
        local c = pTarget:CharacterByID(charid)
        c.flag = curFlag

        pTarget:LoadCharacter(function()
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Приписка успешно добавлена.')
            hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
        end, charid)
    end)
end

netstream.Hook('NextRP::AddCharFlag', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:AddFlag(pPlayer, pTarget, sRank)
end)

function ranks:RemoveFlag(pPlayer, pTarget, sFlag)
    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Отправляем запрос на удаление приписки...')

    local curFlag = pTarget:GetNVar('nrp_charflags') or {}
    if not curFlag[sFlag] then return end
    curFlag[sFlag] = nil

    pTarget:SetCharValue('flag', util.TableToJSON(curFlag), function()
        local c = pTarget:CharacterByID(charid)
        c.flag = curFlag

        pTarget:LoadCharacter(function()
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Приписка успешно удалена.')
            hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
        end, charid)
    end)
end

netstream.Hook('NextRP::RemoveCharFlag', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:RemoveFlag(pPlayer, pTarget, sRank)
end)

NextRP:AddCommand('ranks', function(pPlayer)
    netstream.Start(pPlayer, 'NextRP::OpenSelfRankMenu')
end)