local pMeta = FindMetaTable('Player')

-- Leak by VoLVeR https://vk.com/darkrp_credorp
function pMeta:CharacterByID(character_id)
    for i, char in pairs(self.Characters or {}) do
        if char.character_id == character_id then
            return char
        end
    end
    return false
end

function pMeta:RequestCharacters(cb)
    local playerid = self:GetNVar('nrp_id')

    MySQLite.query(string.format('SELECT * FROM nextrp_characters WHERE player_id = %s;', MySQLite.SQLStr(playerid)), function(characters)
        characters = characters or {}

        for i, char in pairs(characters) do
            characters[i].team_index = NextRP.JobsByID[char.team_id].index

            -- безопасные JSON -> table
            characters[i].flag      = util.JSONToTable(characters[i].flag or "[]")      or {}
            characters[i].inventory = util.JSONToTable(characters[i].inventory or "[]") or {}
            characters[i].model     = util.JSONToTable(characters[i].model or "[]")     or {}

            -- числовые поля
            characters[i].level = tonumber(characters[i].level) or 1
            characters[i].exp   = tonumber(characters[i].exp)   or 0
            characters[i].money = tonumber(characters[i].money) or 0
        end

        -- виртуальный “админ-персонаж”
        if self:IsAdmin() then
            characters[#characters + 1] = {
                character_id = -1,
                character_name = 'Администратор',
                character_nickname = self:OldName(),
                exp = 0,
                flag = {},
                inventory = {},
                level = 1,
                model = {
                    model = 'models/player/hostage/hostage_04.mdl',
                    skin = 0,
                    bodygroups = {}
                },
                money = 500,
                player_id = self:GetNVar('nrp_id'),
                rank = 'ADMIN',
                rpid = '####',
                team_id = 'admin',
                team_index = TEAM_ADMIN,
            }
        end

        if cb then cb(characters) end
        return characters
    end, function(err)
        print(err)
        return err
    end)
end

-- Leak by VoLVeR https://vk.com/darkrp_credorp
function pMeta:LoadCharacter(cb, character_id)
    local char = self:CharacterByID(character_id)
    if not char then
        -- если персонаж не найден, можно ретрайнуться, но сразу выходим
        self:ConCommand('retry')
        return
    end

    -- фикс склейки: сначала сохраняем указатель на активного персонажа
    self.Character = char

    -- числовой левел (и вообще не используем строку)
    local lvl = tonumber(char.level) or 1

    -- NVar для клиента
    self:SetNVar('is_load_char', true, NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_rpname',    (char.character_name or '') .. ' ' .. (char.character_nickname or ''), NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_fullname',  (char.rank or '') .. ' ' .. (char.rpid or '') .. ' ' .. (char.character_nickname or ''), NETWORK_PROTOCOL_PUBLIC)

    self:SetNVar('nrp_name',      char.character_name or '',      NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_nickname',  char.character_nickname or '',  NETWORK_PROTOCOL_PUBLIC)

    self:SetNVar('nrp_faction',   NextRP.JobsByID[char.team_id].type, NETWORK_PROTOCOL_PUBLIC)

    self:SetNVar('nrp_charid', character_id,          NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_rank',   char.rank,             NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_level',  lvl,                   NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('char_level', lvl,                   NETWORK_PROTOCOL_PUBLIC)

    self:SetNVar('nrp_rpid',      char.rpid or '',        NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_charflags', char.flag or {},        NETWORK_PROTOCOL_PUBLIC)
    self:SetNVar('nrp_money',     tonumber(char.money) or 0, NETWORK_PROTOCOL_PUBLIC)

    self:SetTeam(char.team_index)

    -- зачистка невалидных флагов относительно работы
    local jt = NextRP.GetJob(char.team_index)
    for k, v in pairs(char.flag or {}) do
        if istable(jt.flags[k]) then continue end
        char.flag[k] = nil
        self:SetCharValue('flag', util.TableToJSON(char.flag), function()
            self:SetNVar('nrp_charflags', char.flag or {}, NETWORK_PROTOCOL_PUBLIC)
        end)
    end

    -- если был заспавнен транспорт — убрать
    if IsValid(self.SpawnedVeh) then
        self.SpawnedVeh:Remove()
        self.SpawnedVeh = nil
        self:SendMessage(MESSAGE_TYPE_WARNING, 'Ваша техника была возвращена из-за смены персонажа.')
    end

    if cb then cb(char) end
end

-- Leak by VoLVeR https://vk.com/darkrp_credorp
function pMeta:ChangeTeam(team_index, temp, cb)
    team_index = team_index and team_index or error('NoValue')

    local job = NextRP.GetJob(team_index)
    if not job then return end

    local rank = job.ranks[self:GetRank()]
    if not istable(rank) then
        rank = job.default_rank
    else
        rank = self:GetRank()
    end

    if not temp then
        self:SetCharValue('team_id', job.id, function()
            local c = self:CharacterByID(self:GetNVar('nrp_charid'))
            if not c then return end

            c.team_id = job.id

            self:SetCharValue('rank', rank, function()
                c.rank = rank
                c.team_index = team_index
                c.flag = {}
                c.model = {}

                self:LoadCharacter(function()
                    self:SendMessage(MESSAGE_TYPE_WARNING, 'Вам выдали профессию ', job.name, ' на постоянной основе.')
                    hook.Call('PlayerLoadout', GAMEMODE, self)
                end, self:GetNVar('nrp_charid'))
            end)

            self:SetCharValue('model', '[]')
            self:SetCharValue('flag',  '[]')
        end)
    else
        local c = self:CharacterByID(self:GetNVar('nrp_charid'))
        if not c then return end

        c.team_id = job.id
        c.team_index = team_index
        c.rank = rank
        c.flag = {}

        self:LoadCharacter(function()
            self:SendMessage(MESSAGE_TYPE_WARNING, 'Вам выдали профессию ', job.name, ' на время (до перезахода/смены персонажа).')
            hook.Call('PlayerLoadout', GAMEMODE, self)
        end, self:GetNVar('nrp_charid'))
    end
end

netstream.Hook('NextRP::GiveTeam', function(pPlayer, pTarget, iTeam, bTemp)
    if pPlayer:IsAdmin() then pTarget:ChangeTeam(iTeam, bTemp) end

    local pJob = pPlayer:getJobTable()
    local tJob = pTarget:getJobTable()

    local isPHasWL = pJob.ranks[pPlayer:GetRank()].whitelist
    if (iTeam ~= pTarget:Team()) and isPHasWL then
        pTarget:ChangeTeam(iTeam, bTemp)
    end
end)

function pMeta:SetCharValue(name, value, cb)
    value = value and value or error('NoValue')

    local str = isnumber(value) and '%d' or '%s'
    value = isnumber(value) and value or MySQLite.SQLStr(value)

    MySQLite.query(string.format(
        'UPDATE nextrp_characters SET `%s` = ' .. str .. ' WHERE character_id = %s;',
        name,
        value,
        MySQLite.SQLStr(self:GetNVar('nrp_charid'))
    ), function()
        if cb then cb() end
    end)
end

hook.Add('NextRP::PlayerIDRetrived', 'OpenCharsMenu', function(pPlayer)
    pPlayer:RequestCharacters(function(characters)
        pPlayer.Characters = characters or {}
        netstream.Start(pPlayer, 'NextRP::OpenInitCharsMenu', characters or {})
    end)
end)

function pMeta:AddSlot(nSlots)
    local curSlots = tonumber(self:GetNVar('nrp_slots')) or 0
    nSlots = curSlots + (tonumber(nSlots) or 0)

    self:SetNVar('nrp_slots', nSlots, NETWORK_PROTOCOL_PUBLIC)
    self:SavePlayerData('char_slots', nSlots)
end
