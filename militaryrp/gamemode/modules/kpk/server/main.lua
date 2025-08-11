-- Server: KPK (чаты, объявления с подтверждением, задачи, авто-отчёт, утилиты, закреп)
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK  = NextRP.KPK
local CFG = KPK.CFG or function() return (NextRP.KPK and NextRP.KPK.Config) or {} end
local function now() return os.time() end



-- === Вспомогательные ===
local function findChannelDef(catId, chKey)
    local cat = (CFG().categories or {})[catId]
    if not cat then return end
    for _, ch in ipairs(cat.channels or {}) do
        if ch.key == chKey then return ch end
    end
end

local function getVisibleCategoriesFor(ply)
    local out = {}
    for catId, def in pairs(CFG().categories or {}) do
        if NextRP.KPK.CanSeeCategory(ply, catId) then
            out[catId] = def
        end
    end
    return out
end

local function isAdminLike(ply)
    if not IsValid(ply) then return false end
    if ply.IsAdmin and ply:IsAdmin() then return true end
    if (CFG().testing_admin_access and ply:IsAdmin()) then return true end
    return (NextRP.KPK.GetPlayerJobId and NextRP.KPK.GetPlayerJobId(ply) == 'cmd')
end

local function broadcastToCategory(cat, msgName, payload)
    for _, v in ipairs(player.GetAll()) do
        if NextRP.KPK.CanSeeCategory(v, cat) then
            netstream.Start(v, msgName, payload)
        end
    end
end

-- === Bootstrap ===
netstream.Hook('KPK::Bootstrap', function(ply)
    local cats = getVisibleCategoriesFor(ply)

    local acl = {}
    for catId, def in pairs(cats) do
        acl[catId] = acl[catId] or {}
        for _, ch in ipairs(def.channels or {}) do
            acl[catId][ch.key] = {
                can_post = NextRP.KPK.CanPostToChannel(ply, catId, ch),
                can_pin  = NextRP.KPK.CanPinInChannel(ply, catId, ch)
            }
        end
    end

    local pinsMap = {}
    local where = {}
    for catId, def in pairs(cats) do
        for _, ch in ipairs(def.channels or {}) do
            where[#where+1] = string.format("(category=%s AND channel=%s)",
                MySQLite.SQLStr(catId), MySQLite.SQLStr(ch.key))
        end
    end

    local function send(profileSeconds, pins)
        netstream.Start(ply, 'KPK::Bootstrap:OK', {
            categories = cats,
            pins = pins or {},
            acl  = acl,
            profile = {
                playtime = tonumber(profileSeconds or 0) + math.max(0, now() - (ply._kpkSessionStart or now())),
                fullname = ply:GetNVar('nrp_fullname') or ply:Nick(),
                job_id   = NextRP.KPK.GetPlayerJobId(ply),
                rank     = ply.GetRank and ply:GetRank() or '',
                is_admin_like = isAdminLike(ply) and true or false
            }
        })
    end

    local function fetchProfileThenSend(pins)
        MySQLite.queryValue('SELECT playtime FROM kpk_profiles WHERE steam_id=' ..
            MySQLite.SQLStr(ply:SteamID()) .. ' LIMIT 1;', function(v)
            send(tonumber(v or 0), pins)
        end)
    end

    if #where > 0 then
        MySQLite.query('SELECT * FROM kpk_pins WHERE ' .. table.concat(where, ' OR ') .. ';', function(rows)
            for _, r in ipairs(rows or {}) do
                pinsMap[r.category] = pinsMap[r.category] or {}
                pinsMap[r.category][r.channel] = r
            end
            fetchProfileThenSend(pinsMap)
        end)
    else
        fetchProfileThenSend({})
    end
end)

-- === Выборка страницы (с данными по объявлениям) ===
netstream.Hook('KPK::Fetch', function(ply, data)
    if not istable(data) then return end
    local cat, ch, beforeId = data.category, data.channel, tonumber(data.before_id)
    if not NextRP.KPK.CanSeeCategory(ply, cat) then return end
    local chDef = findChannelDef(cat, ch)
    if not chDef then return end

    local limit = math.Clamp(CFG().page_size or 100, 10, 300)
    local where = 'm.category=' .. MySQLite.SQLStr(cat) .. ' AND m.channel=' .. MySQLite.SQLStr(ch)
    if beforeId and beforeId > 0 then where = where .. ' AND m.id < ' .. beforeId end

    local sql = [[
        SELECT m.id, m.category, m.channel, m.steam_id, m.char_id, m.content, m.created_at, m.reply_to, m.edited_at, m.is_announce,
               p.content AS reply_content, p.steam_id AS reply_steam_id, p.created_at AS reply_created_at
        FROM kpk_messages m
        LEFT JOIN kpk_messages p ON p.id = m.reply_to
        WHERE ]] .. where .. [[
        ORDER BY m.id DESC
        LIMIT ]] .. limit .. [[;
    ]]

    MySQLite.query(sql, function(rows)
        rows = rows or {}
        -- объявления — вернём счётчики подтверждений и отметку «я подтвердил»
        local ids = {}
        for _, r in ipairs(rows) do
            if tonumber(r.is_announce or 0) == 1 then ids[#ids+1] = tonumber(r.id) or 0 end
        end
        if #ids == 0 then
            return netstream.Start(ply, 'KPK::Fetch:OK', { category = cat, channel = ch, rows = rows, ann = {counts={}, mine={}} })
        end

        local idlist = table.concat(ids, ',')
        MySQLite.query('SELECT message_id, COUNT(*) AS c FROM kpk_acks WHERE message_id IN ('..idlist..') GROUP BY message_id;', function(rs1)
            local counts = {}
            for _, rr in ipairs(rs1 or {}) do counts[tonumber(rr.message_id) or 0] = tonumber(rr.c) or 0 end
            MySQLite.query('SELECT message_id FROM kpk_acks WHERE message_id IN ('..idlist..') AND steam_id='..MySQLite.SQLStr(ply:SteamID())..';', function(rs2)
                local mine = {}
                for _, rr in ipairs(rs2 or {}) do mine[tonumber(rr.message_id) or 0] = true end
                netstream.Start(ply, 'KPK::Fetch:OK', { category = cat, channel = ch, rows = rows, ann = {counts=counts, mine=mine} })
            end)
        end)
    end)
end)

-- Антиспам постинга
KPK._lastPost = KPK._lastPost or {}

-- Обычный пост сообщения (reply_to)
netstream.Hook('KPK::Post', function(ply, data)
    if not istable(data) then return end
    local cat, ch, text = data.category, data.channel, tostring(data.text or '')
    local replyTo = tonumber(data.reply_to_id or 0) or 0
    if text == '' then return end

    -- throttle
    local sid = ply:SteamID()
    local last = KPK._lastPost[sid] or 0
    if (CurTime() - last) < 0.7 then return end
    KPK._lastPost[sid] = CurTime()

    local chDef = findChannelDef(cat, ch)
    if not chDef or not NextRP.KPK.CanPostToChannel(ply, cat, chDef) then return end

    local function _insert(validReplyId)
        local steam = MySQLite.SQLStr(ply:SteamID())
        local cid   = tonumber(ply:GetNVar('nrp_charid')) or 0
        local content = MySQLite.SQLStr(string.sub(text, 1, 4000))
        local ts = now()
        local replySQL = validReplyId and tostring(validReplyId) or 'NULL'

        local ins = string.format(
            "INSERT INTO kpk_messages(category, channel, steam_id, char_id, content, created_at, reply_to, edited_at, is_announce) VALUES(%s,%s,%s,%d,%s,%d,%s,NULL,0);",
            MySQLite.SQLStr(cat), MySQLite.SQLStr(ch), steam, cid, content, ts, replySQL
        )
        MySQLite.query(ins, function()
            local qlast = MySQLite.isMySQL() and 'SELECT LAST_INSERT_ID() as id;' or 'SELECT last_insert_rowid() as id;'
            MySQLite.query(qlast, function(r)
                local newId = r and r[1] and tonumber(r[1].id) or 0
                local function broadcast(parent)
                    broadcastToCategory(cat, 'KPK::Post:New', {
                        category = cat, channel = ch,
                        row = {
                            id = newId, category = cat, channel = ch,
                            steam_id = ply:SteamID(), char_id = cid, content = tostring(text), created_at = ts,
                            reply_to = validReplyId,
                            reply_content = parent and parent.content or nil,
                            reply_steam_id = parent and parent.steam_id or nil,
                            reply_created_at = parent and parent.created_at or nil,
                            edited_at = nil,
                            is_announce = 0
                        }
                    })
                end
                if validReplyId then
                    MySQLite.query('SELECT content, steam_id, created_at FROM kpk_messages WHERE id=' .. validReplyId .. ' LIMIT 1;', function(pr)
                        broadcast(pr and pr[1] or nil)
                    end)
                else
                    broadcast(nil)
                end
            end)
        end)
    end

    if replyTo > 0 then
        MySQLite.query('SELECT id FROM kpk_messages WHERE id=' .. replyTo ..
                       ' AND category=' .. MySQLite.SQLStr(cat) ..
                       ' AND channel=' .. MySQLite.SQLStr(ch) .. ' LIMIT 1;', function(rows)
            _insert(rows and rows[1] and tonumber(rows[1].id) or nil)
        end)
    else
        _insert(nil)
    end
end)

-- Служебное объявление — создать
netstream.Hook('KPK::Announce:Create', function(ply, data)
    if not istable(data) then return end
    local cat, ch, text = tostring(data.category or ''), tostring(data.channel or ''), tostring(data.text or '')
    if cat == '' or ch == '' or text == '' then return end
    local chDef = findChannelDef(cat, ch)
    if not chDef then return end
    -- право: модератор канала (pin) или админ/командование
    if not (NextRP.KPK.CanPinInChannel(ply, cat, chDef) or isAdminLike(ply)) then return end

    local steam = MySQLite.SQLStr(ply:SteamID())
    local cid   = tonumber(ply:GetNVar('nrp_charid')) or 0
    local content = MySQLite.SQLStr(string.sub(text, 1, 4000))
    local ts = now()

    local ins = string.format(
        "INSERT INTO kpk_messages(category, channel, steam_id, char_id, content, created_at, reply_to, edited_at, is_announce) VALUES(%s,%s,%s,%d,%s,%d,NULL,NULL,1);",
        MySQLite.SQLStr(cat), MySQLite.SQLStr(ch), steam, cid, content, ts
    )
    MySQLite.query(ins, function()
        local qlast = MySQLite.isMySQL() and 'SELECT LAST_INSERT_ID() as id;' or 'SELECT last_insert_rowid() as id;'
        MySQLite.query(qlast, function(r)
            local newId = r and r[1] and tonumber(r[1].id) or 0
            broadcastToCategory(cat, 'KPK::Post:New', {
                category = cat, channel = ch,
                row = {
                    id = newId, category = cat, channel = ch,
                    steam_id = ply:SteamID(), char_id = cid, content = tostring(text), created_at = ts,
                    reply_to = nil, reply_content = nil, reply_steam_id = nil, reply_created_at = nil,
                    edited_at = nil,
                    is_announce = 1,
                    ann_count = 0
                }
            })
        end)
    end)
end)

-- Служебное объявление — подтверждение «прочитал»
netstream.Hook('KPK::Announce:Confirm', function(ply, data)
    if not istable(data) then return end
    local id = tonumber(data.message_id or 0) or 0
    if id <= 0 then return end
    MySQLite.query('SELECT category, is_announce FROM kpk_messages WHERE id='..id..' LIMIT 1;', function(rows)
        local r = rows and rows[1]
        if not r or tonumber(r.is_announce or 0) ~= 1 then return end
        local cat = tostring(r.category or '')
        if not NextRP.KPK.CanSeeCategory(ply, cat) then return end

        local sid = MySQLite.SQLStr(ply:SteamID())
        MySQLite.query('INSERT OR IGNORE INTO kpk_acks(message_id, steam_id, confirmed_at) VALUES('..id..','..sid..','..now()..');', function()
            MySQLite.query('SELECT COUNT(*) AS c FROM kpk_acks WHERE message_id='..id..';', function(cnt)
                local c = cnt and cnt[1] and tonumber(cnt[1].c) or 0
                broadcastToCategory(cat, 'KPK::Announce:Update', { message_id = id, count = c })
            end)
        end)
    end)
end)

-- Служебное объявление — список подтвердивших
netstream.Hook('KPK::Announce:List', function(ply, data)
    if not istable(data) then return end
    local id = tonumber(data.message_id or 0) or 0
    if id <= 0 then return end
    MySQLite.query('SELECT category FROM kpk_messages WHERE id='..id..' LIMIT 1;', function(rows)
        local r = rows and rows[1]; if not r then return end
        local cat = tostring(r.category or '')
        if not NextRP.KPK.CanSeeCategory(ply, cat) then return end

        MySQLite.query('SELECT steam_id, confirmed_at FROM kpk_acks WHERE message_id='..id..' ORDER BY confirmed_at ASC;', function(rs)
            rs = rs or {}
            -- добавим имена онлайн игроков
            local names = {}
            for _, pl in ipairs(player.GetAll()) do names[pl:SteamID()] = pl:GetNVar('nrp_fullname') or pl:Nick() end
            for _, row in ipairs(rs) do row.name = names[tostring(row.steam_id or '')] or row.steam_id end
            netstream.Start(ply, 'KPK::Announce:List:OK', { message_id = id, rows = rs })
        end)
    end)
end)

-- Редактирование сообщения
netstream.Hook('KPK::Edit', function(ply, data)
    if not istable(data) then return end
    local id = tonumber(data.id or 0)
    local newText = tostring(data.text or '')
    if id <= 0 or newText == '' then return end

    MySQLite.query('SELECT * FROM kpk_messages WHERE id='..id..' LIMIT 1;', function(rows)
        local row = rows and rows[1]
        if not row then return end

        local cat, ch = tostring(row.category or ''), tostring(row.channel or '')
        if not NextRP.KPK.CanSeeCategory(ply, cat) then return end

        local isOwner = (tostring(row.steam_id or '') == ply:SteamID())
        local admin = isAdminLike(ply)
        if not (isOwner or admin) then
            return netstream.Start(ply, 'KPK::Edit:Denied', { reason = 'Нет прав' })
        end

        local window = tonumber(CFG().edit_window_sec or 300) or 300
        if (not admin) and (now() - tonumber(row.created_at or now())) > window then
            return netstream.Start(ply, 'KPK::Edit:Denied', { reason = 'Истекло время на редактирование' })
        end

        newText = string.sub(newText, 1, 4000)
        local ts = now()
        MySQLite.query('UPDATE kpk_messages SET content='..MySQLite.SQLStr(newText)..', edited_at='..ts..' WHERE id='..id..';', function()
            broadcastToCategory(cat, 'KPK::Edit:OK', { id = id, category = cat, channel = ch, content = newText, edited_at = ts })
        end)
    end)
end)

-- Удаление одного сообщения (+ снятие пина)
netstream.Hook('KPK::Delete', function(ply, data)
    if not istable(data) then return end
    local id = tonumber(data.id or 0)
    if not id or id <= 0 then return end

    MySQLite.query('SELECT * FROM kpk_messages WHERE id=' .. id .. ' LIMIT 1;', function(rows)
        local row = rows and rows[1]
        if not row then return end

        local cat, ch = tostring(row.category or ''), tostring(row.channel or '')
        if not NextRP.KPK.CanSeeCategory(ply, cat) then return end

        local chDef = findChannelDef(cat, ch)
        if not chDef then return end

        local isOwner = (row.steam_id == ply:SteamID())
        local isModerator = NextRP.KPK.CanPinInChannel(ply, cat, chDef)
        if not (isOwner or isModerator or isAdminLike(ply)) then return end

        MySQLite.query('DELETE FROM kpk_messages WHERE id=' .. id .. ';', function()
            -- удалить подтверждения к объявлению, если было
            MySQLite.query('DELETE FROM kpk_acks WHERE message_id='..id..';')

            MySQLite.query('SELECT * FROM kpk_pins WHERE category=' .. MySQLite.SQLStr(cat) ..
                           ' AND channel=' .. MySQLite.SQLStr(ch) .. ' LIMIT 1;', function(p)
                local pin = p and p[1]
                if pin and tonumber(pin.message_id) == id then
                    MySQLite.query('DELETE FROM kpk_pins WHERE category=' .. MySQLite.SQLStr(cat) ..
                                   ' AND channel=' .. MySQLite.SQLStr(ch) .. ';', function()
                        broadcastToCategory(cat, 'KPK::Pin:Update', { category = cat, channel = ch, pin = nil })
                    end)
                end
            end)

            broadcastToCategory(cat, 'KPK::Delete:OK', { category = cat, channel = ch, id = id })
        end)
    end)
end)

-- === АДМИН-УТИЛИТЫ (bulk) ===
local function broadcastDirty(cat, ch)
    broadcastToCategory(cat, 'KPK::Channel:Dirty', { category = cat, channel = ch })
end

local function ensurePinValidity(cat, ch)
    MySQLite.query('SELECT message_id FROM kpk_pins WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..' LIMIT 1;', function(rp)
        local pin = rp and rp[1]
        if not pin then return end
        local mid = tonumber(pin.message_id or 0) or 0
        if mid <= 0 then
            MySQLite.query('DELETE FROM kpk_pins WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';')
            return
        end
        MySQLite.query('SELECT 1 FROM kpk_messages WHERE id='..mid..' LIMIT 1;', function(ex)
            if not ex or not ex[1] then
                MySQLite.query('DELETE FROM kpk_pins WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';', function()
                    broadcastDirty(cat, ch)
                end)
            end
        end)
    end)
end

netstream.Hook('KPK::Admin:BulkDelete', function(ply, data)
    if not isAdminLike(ply) then return end
    if not istable(data) then return end
    local cat, ch = tostring(data.category or ''), tostring(data.channel or '')
    if cat == '' or ch == '' then return end
    if not NextRP.KPK.CanSeeCategory(ply, cat) then return end

    local mode = tostring(data.mode or '')
    if mode == 'last_n' then
        local n = math.Clamp(tonumber(data.n or 0) or 0, 1, 2000)
        MySQLite.query('SELECT id FROM kpk_messages WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..' ORDER BY id DESC LIMIT '..n..';', function(rows)
            local ids = {}
            for _, r in ipairs(rows or {}) do ids[#ids+1] = tonumber(r.id) or 0 end
            if #ids == 0 then return end
            local idlist = table.concat(ids, ',')
            MySQLite.query('DELETE FROM kpk_acks WHERE message_id IN ('..idlist..');')
            MySQLite.query('DELETE FROM kpk_messages WHERE id IN ('..idlist..');', function()
                ensurePinValidity(cat, ch)
                broadcastDirty(cat, ch)
            end)
        end)

    elseif mode == 'older_than_days' then
        local d = math.Clamp(tonumber(data.days or 0) or 0, 1, 3650)
        local thr = now() - d*24*3600
        MySQLite.query('SELECT id FROM kpk_messages WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..' AND created_at < '..thr..';', function(rows)
            local ids = {}
            for _, r in ipairs(rows or {}) do ids[#ids+1] = tonumber(r.id) or 0 end
            if #ids > 0 then MySQLite.query('DELETE FROM kpk_acks WHERE message_id IN ('..table.concat(ids, ',')..');') end
            MySQLite.query('DELETE FROM kpk_messages WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..' AND created_at < '..thr..';', function()
                ensurePinValidity(cat, ch)
                broadcastDirty(cat, ch)
            end)
        end)

    elseif mode == 'id_range' then
        local a = math.max(0, tonumber(data.a or 0) or 0)
        local b = math.max(0, tonumber(data.b or 0) or 0)
        if a <= 0 or b <= 0 then return end
        if a > b then a, b = b, a end
        MySQLite.query('DELETE FROM kpk_acks WHERE message_id BETWEEN '..a..' AND '..b..';', function()
            MySQLite.query('DELETE FROM kpk_messages WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..' AND id BETWEEN '..a..' AND '..b..';', function()
                ensurePinValidity(cat, ch)
                broadcastDirty(cat, ch)
            end)
        end)

    elseif mode == 'wipe_channel' then
        MySQLite.query('SELECT id FROM kpk_messages WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';', function(rows)
            local ids = {}
            for _, r in ipairs(rows or {}) do ids[#ids+1] = tonumber(r.id) or 0 end
            if #ids > 0 then
                MySQLite.query('DELETE FROM kpk_acks WHERE message_id IN ('..table.concat(ids, ',')..');')
            end
            MySQLite.query('DELETE FROM kpk_messages WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';', function()
                MySQLite.query('DELETE FROM kpk_pins WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';', function()
                    broadcastDirty(cat, ch)
                end)
            end)
        end)
    end
end)

-- === ЗАКРЕП (set/clear) ===
netstream.Hook('KPK::Pin:Set', function(ply, data)
    if not istable(data) then return end
    local cat, ch, id = tostring(data.category or ''), tostring(data.channel or ''), tonumber(data.message_id or 0) or 0
    if cat=='' or ch=='' or id<=0 then return end
    local chDef = findChannelDef(cat, ch); if not chDef then return end
    if not (NextRP.KPK.CanPinInChannel(ply, cat, chDef) or isAdminLike(ply)) then return end

    MySQLite.query('SELECT 1 FROM kpk_messages WHERE id='..id..' AND category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..' LIMIT 1;', function(rows)
        if not rows or not rows[1] then return end
        MySQLite.query('DELETE FROM kpk_pins WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';', function()
            MySQLite.query(string.format(
                "INSERT INTO kpk_pins(category,channel,message_id,pinned_by,pinned_at) VALUES(%s,%s,%d,%s,%d);",
                MySQLite.SQLStr(cat), MySQLite.SQLStr(ch), id, MySQLite.SQLStr(ply:SteamID()), now()
            ), function()
                broadcastToCategory(cat, 'KPK::Pin:Update', { category=cat, channel=ch, pin={category=cat,channel=ch,message_id=id,pinned_by=ply:SteamID(),pinned_at=now()} })
            end)
        end)
    end)
end)

netstream.Hook('KPK::Pin:Clear', function(ply, data)
    if not istable(data) then return end
    local cat, ch = tostring(data.category or ''), tostring(data.channel or '')
    if cat=='' or ch=='' then return end
    local chDef = findChannelDef(cat, ch); if not chDef then return end
    if not (NextRP.KPK.CanPinInChannel(ply, cat, chDef) or isAdminLike(ply)) then return end

    MySQLite.query('DELETE FROM kpk_pins WHERE category='..MySQLite.SQLStr(cat)..' AND channel='..MySQLite.SQLStr(ch)..';', function()
        broadcastToCategory(cat, 'KPK::Pin:Update', { category=cat, channel=ch, pin=nil })
    end)
end)

-- === ЗАДАЧИ ===
local function canManageTasks(ply, cat)
    if not NextRP.KPK.CanSeeCategory(ply, cat) then return false end
    if isAdminLike(ply) then return true end
    local catDef = (CFG().categories or {})[cat]
    if not catDef then return false end
    local reportsCh
    for _, ch in ipairs(catDef.channels or {}) do if ch.key == 'reports' then reportsCh = ch break end end
    if reportsCh then return NextRP.KPK.CanPinInChannel(ply, cat, reportsCh) end
    return false
end

netstream.Hook('KPK::Tasks:List', function(ply, data)
    if not istable(data) then return end
    local cat = tostring(data.category or '')
    if cat == '' or not NextRP.KPK.CanSeeCategory(ply, cat) then return end

    MySQLite.query('SELECT * FROM kpk_tasks WHERE category='..MySQLite.SQLStr(cat)..' ORDER BY (status!="done"), deadline ASC NULLS LAST, id DESC;', function(rows)
        rows = rows or {}
        local names = {}
        for _, pl in ipairs(player.GetAll()) do names[pl:SteamID()] = pl:GetNVar('nrp_fullname') or pl:Nick() end
        for _, r in ipairs(rows) do
            r.assignee_name = (r.assignee_sid and names[r.assignee_sid]) or r.assignee_sid or ''
            r.creator_name  = (r.creator_sid and names[r.creator_sid]) or r.creator_sid or ''
        end
        netstream.Start(ply, 'KPK::Tasks:List:OK', { category = cat, tasks = rows })
    end)
end)

netstream.Hook('KPK::Tasks:Create', function(ply, data)
    if not istable(data) then return end
    local cat = tostring(data.category or '')
    local title = tostring(data.title or '')
    local desc  = tostring(data.description or '')
    local assignee = tostring(data.assignee_sid or '')
    local deadline = tonumber(data.deadline or 0) or 0
    if cat=='' or title=='' then return end
    if not canManageTasks(ply, cat) then return end

    local sql = string.format(
        "INSERT INTO kpk_tasks(category,title,description,creator_sid,assignee_sid,status,deadline,created_at,closed_at) VALUES(%s,%s,%s,%s,%s,%s,%d,%d,NULL);",
        MySQLite.SQLStr(cat), MySQLite.SQLStr(string.sub(title,1,200)),
        MySQLite.SQLStr(string.sub(desc,1,2000)),
        MySQLite.SQLStr(ply:SteamID()), (assignee ~= '' and MySQLite.SQLStr(assignee) or "NULL"),
        MySQLite.SQLStr('open'), deadline, now()
    )
    MySQLite.query(sql, function()
        local qlast = MySQLite.isMySQL() and 'SELECT LAST_INSERT_ID() as id;' or 'SELECT last_insert_rowid() as id;'
        MySQLite.query(qlast, function(r)
            local id = r and r[1] and tonumber(r[1].id) or 0
            broadcastToCategory(cat, 'KPK::Tasks:Updated', { category=cat, action='create', id=id })
        end)
    end)
end)

netstream.Hook('KPK::Tasks:Update', function(ply, data)
    if not istable(data) then return end
    local id = tonumber(data.id or 0) or 0
    if id<=0 then return end
    MySQLite.query('SELECT * FROM kpk_tasks WHERE id='..id..' LIMIT 1;', function(rows)
        local t = rows and rows[1]; if not t then return end
        local cat = tostring(t.category or '')
        if not NextRP.KPK.CanSeeCategory(ply, cat) then return end

        local fields = {}
        local admin = canManageTasks(ply, cat)
        local isAssignee = (t.assignee_sid or '') == ply:SteamID()
        local st = tostring(data.status or '')
        if st ~= '' and (isAssignee or admin) then fields[#fields+1] = "status="..MySQLite.SQLStr(st) end

        if admin then
            if data.assignee_sid ~= nil then
                if data.assignee_sid == '' then fields[#fields+1] = "assignee_sid=NULL"
                else fields[#fields+1] = "assignee_sid="..MySQLite.SQLStr(tostring(data.assignee_sid)) end
            end
            if data.title then fields[#fields+1] = "title="..MySQLite.SQLStr(string.sub(tostring(data.title),1,200)) end
            if data.description then fields[#fields+1] = "description="..MySQLite.SQLStr(string.sub(tostring(data.description),1,2000)) end
            if data.deadline ~= nil then
                local dl = tonumber(data.deadline or 0) or 0
                fields[#fields+1] = "deadline="..tostring(dl)
            end
        end

        if #fields == 0 then return end
        local sql = 'UPDATE kpk_tasks SET '..table.concat(fields, ',')..' WHERE id='..id..';'
        MySQLite.query(sql, function()
            broadcastToCategory(cat, 'KPK::Tasks:Updated', { category=cat, action='update', id=id })
        end)
    end)
end)

netstream.Hook('KPK::Tasks:Delete', function(ply, data)
    if not istable(data) then return end
    local id = tonumber(data.id or 0) or 0
    if id<=0 then return end
    MySQLite.query('SELECT category FROM kpk_tasks WHERE id='..id..' LIMIT 1;', function(rows)
        local t = rows and rows[1]; if not t then return end
        local cat = tostring(t.category or '')
        if not canManageTasks(ply, cat) then return end
        MySQLite.query('DELETE FROM kpk_tasks WHERE id='..id..';', function()
            broadcastToCategory(cat, 'KPK::Tasks:Updated', { category=cat, action='delete', id=id })
        end)
    end)
end)

-- === АВТО-ОТЧЁТ ПО СМЕНЕ ===
netstream.Hook('KPK::Reports:AutoPost', function(ply, data)
    if not istable(data) then return end
    local cat = tostring(data.category or '')
    local ch  = tostring(data.channel or 'reports')
    local startt = tostring(data.start_text or '')
    local endt   = tostring(data.end_text or '')
    local body   = tostring(data.body or '')
    if cat=='' or ch=='' or body=='' then return end
    local chDef = findChannelDef(cat, ch); if not chDef then return end
    if not NextRP.KPK.CanPostToChannel(ply, cat, chDef) then return end

    local header = string.format("[ОТЧЁТ ПО СМЕНЕ]\nСмена: %s — %s\nИсполнитель: %s (%s)\n---\n%s",
        startt ~= '' and startt or 'не указано',
        endt   ~= '' and endt   or 'не указано',
        ply:GetNVar('nrp_fullname') or ply:Nick(),
        ply:SteamID(),
        body
    )
    netstream.Hook('KPK::Post')(ply, { category=cat, channel=ch, text=header })
end)
