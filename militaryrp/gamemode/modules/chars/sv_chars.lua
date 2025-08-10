include("modules/inventory/sv_inventory.lua")

local chars = NextRP.Chars or {}
-- Leak by VoLVeR https://vk.com/darkrp_credorp
chars.Cache = {}

function chars:NewChar(pPlayer, tData)
    local number = tData['number'] or 'Unset'
    local nickname = tData['nickname'] or 'Unset'

    local start_team = START_TEAMS[tData['faction']] or 1001
    local start_team_id = (NextRP.Jobs[start_team] or {id = 'none'}).id
    local start_rank = (NextRP.Jobs[start_team] or {default_rank = 'none'}).default_rank
    local rpid = number -- chars:GenerateID(tData['faction'])

    local steamid = pPlayer:SteamID() -- не используеться
    local playerid = pPlayer:GetNVar('nrp_id')

    local curChars = pPlayer.Characters or {}

    if start_team == 1001 then
        netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', curChars, {col = Color(224, 164, 43), text = 'Эта фракция не настроена, обратитесь к тех. администратору!'})
        return
    end

    local maxChars = pPlayer:GetNVar('nrp_slots') or 1

    if pPlayer:IsAdmin() then
        maxChars = maxChars + 1
    end

    if #curChars >= maxChars then return end

    MySQLite.query(string.format('SELECT * FROM `nextrp_characters` WHERE rpid = %s', 
        MySQLite.SQLStr(rpid)
    ), function(chars)
        if istable(chars) then
            netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', curChars, {col = Color(194, 54, 22), text = 'Персонаж с номером '.. tostring(number) ..' уже существует, выберите другой номер!'})
            return
        else
            MySQLite.query(string.format('INSERT INTO `nextrp_characters`(player_id, rpid, `rank`, `flag`, character_name, character_nickname, team_id, model, money, level, exp, inventory) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);',
                playerid,
                MySQLite.SQLStr(rpid),
                MySQLite.SQLStr(start_rank),
                MySQLite.SQLStr(util.TableToJSON({})),
                MySQLite.SQLStr(number),
                MySQLite.SQLStr(nickname),
                MySQLite.SQLStr(start_team_id),
                MySQLite.SQLStr(util.TableToJSON({})),
                NextRP.Config.StartMoney or 1,
                1,
                0,
                MySQLite.SQLStr(util.TableToJSON({}))
            ), function(e, char_id)
                local newChar = {
                    player_id = playerid,
                    character_id = char_id,
                    rpid = rpid,
                    rank = start_rank,
                    team_id = start_team_id,
                    character_name = number,
                    character_nickname = nickname,
                    model = {},
                    level = 1,
                    exp = 0,
                    money = NextRP.Config.StartMoney or 1,
                    flag = {},
                    inventory = {}
                }

                curChars[#curChars + 1] = newChar

                -- TODO: Отправить на клиент новый список персонажей
                pPlayer:RequestCharacters(function(characters)
                    pPlayer.Characters = characters or {}
                    netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {col = Color(0, 255, 0), text = 'Персонаж создан!'})
                end)
            end,
            function(e) print(e) end)
        end
    end)
end

netstream.Hook('NextRP::CreateNewChar', function(pPlayer, tData)   
    if not IsValid(pPlayer) then print(1) return end
    if not istable(tData) then print(2) return end

    chars:NewChar(pPlayer, tData)
end)

function chars:DeleteChar(pPlayer, tData)
    local can_remove = true
    local charid = tData.character_id

    if pPlayer:GetNVar('nrp_charid') == charid then
        pPlayer:RequestCharacters(function(characters)
            pPlayer.Characters = characters
            netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {text = 'Вы не можете удалить персонажа, играя за него!', col = Color(255, 0, 0)})
        end)
        return
    end

    -- for k, char in pairs(pPlayer.Characters) do
    --     if char.c_id ~= charid then continue end
    --     if NextRP:getTeamByID(char.c_id).start ~= true then
    --         -- TODO: Отправить ошибку на клитентский интерфейс
    --         -- 'Вы не можете удалить персонажа с стартовой профессией.'

    --         break 
    --     else
    --         can_remove = true
    --         break
    --     end
    -- end

    if can_remove == true then
        MySQLite.query(string.format('DELETE FROM `nextrp_characters` WHERE character_id = %s;', charid), function()
            pPlayer:RequestCharacters(function(characters)
                pPlayer.Characters = characters
                netstream.Start(pPlayer, 'NextRP::OpenInitCharsMenu', characters)
            end)
        end)
    end
end
-- Leak by VoLVeR https://vk.com/darkrp_credorp
netstream.Hook('NextRP::DeleteChar', function(pPlayer, tData)
    if not IsValid(pPlayer) then return end
    if not istable(tData) then return end

    chars:DeleteChar(pPlayer, tData)
end)

function chars:ChooseChar(pPlayer, tData)    
    local character_id = tData.character_id

    if not character_id then return end
    if not pPlayer:CharacterByID(character_id) then return end

    if character_id == -1 and not pPlayer:IsAdmin() then
        pPlayer:RequestCharacters(function(characters)
            pPlayer.Characters = characters
            netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {text = 'Вы не использовать этого персонажа!', col = Color(255, 0, 0)})
        end)
        return
    end

    if pPlayer:GetNVar('Arrested') then
        return
    end

    pPlayer:LoadCharacter(function(char)       
        pPlayer:StripWeapons()
        pPlayer:Spawn()
            
                    -- ЗАВАНТАЖЕННЯ ІНВЕНТАРЯ ДЛЯ ОБРАНОГО ПЕРСОНАЖА
        pPlayer.nrp_charid = character_id
        LoadInventory(pPlayer)
    end, character_id)
end

netstream.Hook('NextRP::ChooseChar', function(pPlayer, tData)
    if not IsValid(pPlayer) then return end
    if not istable(tData) then return end

    chars:ChooseChar(pPlayer, tData)
end)