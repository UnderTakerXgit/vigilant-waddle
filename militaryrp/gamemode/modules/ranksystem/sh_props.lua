local ranks = NextRP.Ranks

---------------------------------------------------------------------
-- ОТКРЫТИЕ UI РАНГОВ
---------------------------------------------------------------------
properties.Add("openrank", {
    MenuLabel = "Управление персонажем",
    Order = 1,
    MenuIcon = "icon16/database_edit.png",

    Filter = function(self, ent)
        if not ent:IsPlayer() then return false end
        return ranks:Can(LocalPlayer(), ent) == true
    end,

    Action = function(self, ent)
        ranks:OpenUI(ent)
    end,
})

---------------------------------------------------------------------
-- СЛОТЫ
---------------------------------------------------------------------
properties.Add("slots", {
    MenuLabel   = "Управление слотами",
    Order       = 1,
    MenuIcon    = "icon16/database_edit.png",

    Filter = function(self, ent)
        return ent:IsPlayer() and LocalPlayer():IsSuperAdmin()
    end,

    Action = function(self, ent)
        PAW_MODULE("lib"):DoStringRequest(
            "Введите кол-во слотов",
            "Введите кол-во слотов (Указано столько сколько у человека сейчас): ",
            tostring(ent:GetNVar("nrp_slots") or 0),
            function(sValue)
                properties.Get("slots"):MsgStart()
                    net.WriteEntity(ent)
                    net.WriteString(sValue or "0")
                properties.Get("slots"):MsgEnd()
            end,
            nil, "Применить", "Отмена"
        )
    end,

    Receive = function(self, length, ply)
        local ent   = net.ReadEntity()
        local slots = tonumber(net.ReadString() or "0")

        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not slots then return end

        ent:SetNVar("nrp_slots", slots, NETWORK_PROTOCOL_PUBLIC)
        ent:SavePlayerData("char_slots", slots)
    end
})

---------------------------------------------------------------------
-- РЕПУТАЦИЯ / УРОВЕНЬ
---------------------------------------------------------------------
properties.Add("level", {
    MenuLabel   = "Управление репутацией",
    Order       = 1,
    MenuIcon    = "icon16/star.png",

    Filter = function(self, ent)
        return ent:IsPlayer() and LocalPlayer():IsSuperAdmin()
    end,

    Action = function(self, ent)
        -- запросить актуальное значение у сервера
        net.Start("nrp_get_char_level")
            net.WriteEntity(ent)
        net.SendToServer()
    end,

    Receive = function(self, length, ply)
        local ent   = net.ReadEntity()
        local level = net.ReadUInt(16)

        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        if not IsValid(ent) or not ent:IsPlayer() then return end

        -- обновить кэш и NVares
        ent:SetNVar("nrp_level", level, NETWORK_PROTOCOL_PUBLIC)
        ent:SetNVar("char_level", level, NETWORK_PROTOCOL_PUBLIC)
        if ent.Character then ent.Character.level = level end

        -- сохранить в БД по персонажу
        local cid = ent:GetNVar("nrp_charid")
        if cid then
            MySQLite.query(string.format(
                "UPDATE nextrp_characters SET level = %s WHERE character_id = %s;",
                tonumber(level) or 0, tonumber(cid) or 0
            ))
        end
    end
})

---------------------------------------------------------------------
-- СЕТЬ
---------------------------------------------------------------------
-- серверный приём запроса от клиента
if SERVER then
    util.AddNetworkString("nrp_get_char_level")
    util.AddNetworkString("nrp_get_char_level_reply")

    net.Receive("nrp_get_char_level", function(len, ply)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end

        local ent = net.ReadEntity()
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local level = tonumber(ent:GetNVar("nrp_level"))
                   or (ent.Character and tonumber(ent.Character.level))
                   or 1

        print("Отправка уровня для игрока " .. ent:Nick() .. ": " .. level)
        net.Start("nrp_get_char_level_reply")
            net.WriteUInt(ent:EntIndex(), 16)
            net.WriteUInt(level, 16)
        net.Send(ply)
    end)
end

-- клиентский приём ответа от сервера
if CLIENT then
    net.Receive("nrp_get_char_level_reply", function()
        local idx = net.ReadUInt(16)
        local cur = net.ReadUInt(16)

        local target = Entity(idx)
        if not IsValid(target) or not target:IsPlayer() then
            print("Ошибка: Неверная или не игрок сущность для индекса " .. idx)
            return
        end

        PAW_MODULE("lib"):DoStringRequest(
            "Введите репутацию",
            "Введите реп. (Указано столько сколько у человека сейчас):",
            tostring(cur),
            function(sValue)
                local val = tonumber(sValue) or cur
                local prop = properties.List["level"] -- Получаем объект свойства "level"
                if prop then
                    prop:MsgStart()
                        net.WriteEntity(target)
                        net.WriteUInt(val, 16)
                    prop:MsgEnd()
                else
                    print("Ошибка: Свойство 'level' не найдено в таблице properties")
                end
            end,
            nil, "Применить", "Отмена"
        )
    end)
end