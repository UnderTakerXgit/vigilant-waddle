-- Client: KPK (чаты, объявления с подтверждением, задачи, авто-отчёт, админ-утилиты, интеграции)
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK = NextRP.KPK
local function CFG() return (NextRP.KPK and NextRP.KPK.Config) or {} end

KPK.UI = KPK.UI or nil
KPK._buffers = KPK._buffers or {}   -- key "cat/ch" -> rows (DESC: новые в начале)
KPK._minId   = KPK._minId   or {}   -- key -> минимальный id в буфере
KPK._awaitOlderFor = nil
KPK._prevScroll = KPK._prevScroll or {}
KPK._prevTall   = KPK._prevTall or {}
KPK._fetchCD    = 0
KPK._autoBottom = true
KPK._reply      = nil               -- { id, content, steam_id, created_at }
KPK._linkCache  = KPK._linkCache or {}
KPK._drafts     = KPK._drafts or {}
KPK._annCounts  = KPK._annCounts or {}  -- message_id -> count
KPK._annMine    = KPK._annMine or {}    -- message_id -> true
KPK._tasks      = KPK._tasks or {}      -- category -> list
KPK._mode       = KPK._mode or 'chat'   -- 'chat' | 'tasks'

local function keyFor(cat, ch) return tostring(cat or '') .. '/' .. tostring(ch or '') end
local function table_count(t) local n=0 for _ in pairs(t or {}) do n=n+1 end return n end
local function truncate(s, n) s = tostring(s or '') if #s > n then return string.sub(s,1,n-1)..'…' end return s end
local function btnNoText(b) if b and b.SetText then b:SetText('') end return b end

-- ========== Черновики ==========
local DRAFTS_FILE = 'kpk_drafts.txt'
local function loadDrafts()
    if file.Exists(DRAFTS_FILE, 'DATA') then
        local ok, tbl = pcall(util.JSONToTable, file.Read(DRAFTS_FILE, 'DATA') or '{}'); if ok and istable(tbl) then KPK._drafts = tbl return end
    end
    KPK._drafts = {}
end
local function saveDrafts()
    file.Write(DRAFTS_FILE, util.TableToJSON(KPK._drafts or {}, true))
end

-- ========== Mentions ==========
local function sanitize(s) s = tostring(s or '') return string.Trim(string.lower(s)) end
local function isMentionedForLocal(text, catId)
    text = sanitize(text or '')
    if text == '' then return false end
    local lp = LocalPlayer()
    local nick = sanitize(lp:Nick())
    local fullname = sanitize(lp:GetNVar('nrp_fullname') or '')
    local callsign = sanitize(lp:GetNVar('nrp_nickname') or '')
    local rpid = sanitize(lp:GetNVar('nrp_rpid') or '')
    local jid = NextRP.KPK.GetPlayerJobId and (NextRP.KPK.GetPlayerJobId(lp) or '') or ''
    local jidL = sanitize(jid)
    local function hasToken(tok) if tok=='' then return false end; return text:find('@'..tok,1,true) or (tok:sub(1,1)=='#' and text:find(tok,1,true)) end
    if hasToken(nick) or hasToken(fullname) or hasToken(callsign) or (rpid~='' and hasToken('#'..rpid)) then return true end
    if hasToken(jidL) or hasToken(catId or '') or hasToken('all') or hasToken('here') then return true end
    return false
end

-- ========== Links ==========
local function extractFirstUrl(text)
    if not text or text == "" then return nil end
    local url = string.match(text, "(https?://[%w%-%._%?%.:/%+=&#%%@~]+)")
    if not url then return nil end
    url = string.gsub(url, "[%.,%)%]%}]+$", "")
    return url
end
local function isImageUrl(url) url=string.lower(url or ""); return url:find("%.png$") or url:find("%.jpe?g$") or url:find("%.gif$") or url:find("%.webp$") end
local function parseYouTubeId(url) return string.match(url or "", "youtu%.be/([%w%-%_]+)") or string.match(url or "", "[%?&]v=([%w%-%_]+)") end
local function urlHost(u) return string.match(u or "", "^https?://([^/%?#:]+)") or "link" end
local function buildLinkPreview(parent, url)
    if not IsValid(parent) then return end
    local wrap = TDLib('DPanel', parent)
    wrap:Dock(TOP) wrap:SetTall(0) wrap:DockMargin(8,6,8,10) wrap:ClearPaint()
    if isImageUrl(url) then
        local h = 220
        wrap:SetTall(h+8)
        wrap.Paint = function(s,w,h2) draw.RoundedBox(10, 0,0,w,h2, Color(47,49,54)) end
        local html = vgui.Create('DHTML', wrap)
        html:Dock(FILL); if html.SetAllowLua then html:SetAllowLua(false) end
        local wcss = [[<style>body{margin:0;background:transparent;}img{max-width:100%;height:auto;display:block;border-radius:10px;}</style>]]
        html:SetHTML(wcss..[[<img src="]]..url..[["/>]])
        html.DoClick = function() gui.OpenURL(url) end
        return wrap
    end
    local yt = parseYouTubeId(url)
    if yt then
        local h = 260
        wrap:SetTall(h+8)
        wrap.Paint = function(s,w,h2) draw.RoundedBox(10, 0,0,w,h2, Color(47,49,54)) end
        local html = vgui.Create('DHTML', wrap)
        html:Dock(FILL); if html.SetAllowLua then html:SetAllowLua(false) end
        local wcss = [[<style>html,body{margin:0;height:100%;background:transparent;}iframe{border:0;width:100%;height:100%;border-radius:10px;}</style>]]
        html:SetHTML(wcss..[[<iframe src="https://www.youtube.com/embed/]]..yt..[[" allowfullscreen></iframe>]])
        return wrap
    end
    wrap:SetTall(96)
    wrap.Paint = function(s,w,h) draw.RoundedBox(10, 0,0,w,h, Color(47,49,54)) end
    local ttl = TDLib('DLabel', wrap) ttl:Dock(TOP) ttl:SetTall(30) ttl:DockMargin(12,10,12,0)
    ttl:SetFont('font_sans_21') ttl:SetTextColor(Color(255,255,255))
    ttl:SetText(urlHost(url).." — загрузка заголовка…")
    local desc = TDLib('DLabel', wrap) desc:Dock(TOP) desc:SetTall(24) desc:DockMargin(12,2,12,12)
    desc:SetFont('font_sans_18') desc:SetTextColor(Color(200,200,200))
    desc:SetText(url)
    http.Fetch(url, function(body)
        local title = string.match(body or "", "<title>(.-)</title>")
        if title then title = (title:gsub("%s+", " ")):Trim() end
        if title and title ~= "" then ttl:SetText(truncate(title, 120)) end
    end)
    wrap.OnMouseReleased = function(_, mc) if mc == MOUSE_LEFT then gui.OpenURL(url) end end
    return wrap
end

-- ===================================

local function OpenKPK()
    if IsValid(KPK.UI) then KPK.UI:Remove() KPK.UI = nil end
    loadDrafts()
    netstream.Start('KPK::Bootstrap')
end

netstream.Hook('KPK::Bootstrap:OK', function(payload)
    local cats    = payload.categories or {}
    local pins    = payload.pins or {}
    local acl     = payload.acl or {}
    local profile = payload.profile or {}
    local isAdminLike = payload.profile and payload.profile.is_admin_like == true

    local sw, sh = ScrW(), ScrH()

    local frame = TDLib('DFrame')
    frame:SetSize(math.min(1200, sw * 0.88), math.min(760, sh * 0.88))
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        Derma_DrawBackgroundBlur(s, s.m_fCreateTime or SysTime())
        draw.RoundedBox(16, 0, 0, w, h, Color(40,43,48,230))
        surface.SetDrawColor(255,255,255,8); surface.DrawOutlinedRect(0,0,w,h,2)
    end
    frame.OnKeyCodePressed = function(s, key) if key == KEY_ESCAPE then s:Close() end end
    frame.OnRemove = function()
        if KPK._active and IsValid(KPK.UI) == false then
            local k = keyFor(KPK._active.cat, KPK._active.ch)
            if IsValid(KPK._entry) then KPK._drafts[k] = KPK._entry:GetValue() or '' end
        end
        file.Write(DRAFTS_FILE, util.TableToJSON(KPK._drafts or {}, true))
        KPK._active, KPK.UI, KPK._entry = nil, nil, nil
        KPK._awaitOlderFor = nil
        KPK._reply = nil
        KPK._mode = 'chat'
    end
    KPK.UI = frame

    -- Кнопка закрытия
    local closeBtn = TDLib('DButton', frame)
    closeBtn:SetSize(32,32); closeBtn:SetPos(frame:GetWide()-40,10); closeBtn:ClearPaint(); btnNoText(closeBtn)
    closeBtn:Text('✖','font_sans_21',Color(220,220,220),TEXT_ALIGN_CENTER,0)
    closeBtn.DoClick = function() if IsValid(frame) then frame:Close() end end
    frame.OnSizeChanged = function() if IsValid(closeBtn) then closeBtn:SetPos(frame:GetWide()-40,10) end end

    -- Левая колонка
    local left = TDLib('DPanel', frame) left:Dock(LEFT) left:SetWide(300) left:ClearPaint() left:Background(Color(32,34,37))

    local header = TDLib('DPanel', left) header:Dock(TOP) header:SetTall(120) header:ClearPaint()
    local avatarWrap = TDLib('DPanel', header) avatarWrap:Dock(LEFT) avatarWrap:SetWide(96) avatarWrap:ClearPaint()
    local avatar = TDLib('DPanel', avatarWrap) avatar:Dock(FILL) avatar:ClearPaint() avatar:CircleAvatar() avatar:SetPlayer(LocalPlayer(), 96)
    local nameWrap = TDLib('DPanel', header) nameWrap:Dock(FILL) nameWrap:ClearPaint()
    local nameLine = TDLib('DPanel', nameWrap) nameLine:Dock(TOP) nameLine:SetTall(28) nameLine:ClearPaint()
    nameLine:Text(profile.fullname or LocalPlayer():Nick(), 'font_sans_21', Color(255,255,255), TEXT_ALIGN_LEFT, 8)
    local subLine = TDLib('DPanel', nameWrap) subLine:Dock(TOP) subLine:SetTall(22) subLine:ClearPaint()
    subLine:Text(string.format('%s • %s', profile.rank or '', string.upper(profile.job_id or '')),
                 'font_sans_18', Color(180,180,186), TEXT_ALIGN_LEFT, 8)
    local playLine = TDLib('DPanel', nameWrap) playLine:Dock(TOP) playLine:SetTall(20) playLine:ClearPaint()
    local hours = math.floor((tonumber(profile.playtime or 0) / 3600))
    playLine:Text('В секторе: ~'..hours..' ч.', 'font_sans_16', Color(150,150,155), TEXT_ALIGN_LEFT, 8)
    local callsignLine = TDLib('DPanel', nameWrap) callsignLine:Dock(TOP) callsignLine:SetTall(20) callsignLine:ClearPaint()
    local nick = LocalPlayer():GetNVar('nrp_nickname') or ''
    local rpid = LocalPlayer():GetNVar('nrp_rpid') or ''
    local callsignTxt = (nick ~= '' and nick or '—') .. ((rpid ~= '' and (' • №'..rpid)) or '')
    callsignLine:Text(callsignTxt, 'font_sans_16', Color(180,180,186), TEXT_ALIGN_LEFT, 8)

    local catsScroll = TDLib('DScrollPanel', left) catsScroll:Dock(FILL) catsScroll:ClearPaint()

    -- нижняя «шестерёнка» (инструменты/интеграции)
    local gearBar = TDLib('DPanel', left) gearBar:Dock(BOTTOM) gearBar:SetTall(52) gearBar:ClearPaint()
    local gearBtn = TDLib('DButton', gearBar) gearBtn:Dock(FILL) gearBtn:DockMargin(8,8,8,8) gearBtn:ClearPaint(); btnNoText(gearBtn)
    gearBtn.Paint = function(s,w,h)
        if not isAdminLike then return end
        draw.RoundedBox(10,0,0,w,h, Color(48,51,57))
        draw.SimpleText('⚙  Инструменты', 'font_sans_18', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    gearBtn:SetVisible(isAdminLike)

    -- Правая часть
    local right = TDLib('DPanel', frame) right:Dock(FILL) right:ClearPaint()
    local title = TDLib('DPanel', right) title:Dock(TOP) title:SetTall(64) title:ClearPaint()
    title:Text('КПК', 'font_sans_24', Color(255,255,255), TEXT_ALIGN_LEFT, 10)

    -- Переключатель режимов: Чаты / Задачи
    local modeTabs = TDLib('DPanel', title) modeTabs:Dock(RIGHT) modeTabs:SetWide(240) modeTabs:ClearPaint()
    local function mkTab(txt, val)
        local b = TDLib('DButton', modeTabs) b:Dock(LEFT) b:SetWide(120) b:DockMargin(8,10,0,10) b:ClearPaint(); btnNoText(b)
        b.Paint = function(s,w,h)
            local on = (KPK._mode == val)
            draw.RoundedBox(10,0,0,w,h, on and Color(88,101,242) or Color(60,63,68))
            draw.SimpleText(txt, 'font_sans_18', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function()
            KPK._mode = val
            if val == 'tasks' then
                if KPK._active then netstream.Start('KPK::Tasks:List', { category = KPK._active.cat }) end
            end
            right:InvalidateLayout(true)
        end
        return b
    end
    local tabChat  = mkTab('Чаты','chat')
    local tabTasks = mkTab('Задачи','tasks')

    -- ====== Интеграции ======
    local function openAutoReportDialog()
        if not (KPK._active and KPK._active.ch == 'reports') then
            notification.AddLegacy('Авто-отчёт доступен только в канале "Отчётность".', NOTIFY_HINT, 3)
            surface.PlaySound('buttons/button15.wav')
            return
        end
        local fr = vgui.Create('DFrame') fr:SetTitle('Авто-отчёт по смене') fr:SetSize(520, 460) fr:Center() fr:MakePopup()
        local s1 = vgui.Create('DTextEntry', fr) s1:SetPos(12,36)  s1:SetSize(496,28)  s1:SetText('Начало (напр. 10:00)')
        local s2 = vgui.Create('DTextEntry', fr) s2:SetPos(12,68)  s2:SetSize(496,28)  s2:SetText('Окончание (напр. 18:00)')
        local s3 = vgui.Create('DTextEntry', fr) s3:SetPos(12,100) s3:SetSize(496,320) s3:SetMultiline(true) s3:SetText('Краткий отчёт: …')
        local ok = vgui.Create('DButton', fr)  ok:SetPos(12,430) ok:SetSize(496,24) ok:SetText('Опубликовать')
        ok.DoClick = function()
            local a = string.Trim(s1:GetValue() or '')
            local b = string.Trim(s2:GetValue() or '')
            local c = string.Trim(s3:GetValue() or '')
            if c == '' then return end
            netstream.Start('KPK::Reports:AutoPost', { category=KPK._active.cat, channel='reports', start_text=a, end_text=b, body=c })
            fr:Close()
        end
    end

    local function openCreateAnnounceDialog()
        if not KPK._active then return end
        Derma_StringRequest('Служебное объявление', 'Введите текст объявления (оно получит кнопку «Прочитал»):', '', function(txt)
            txt = string.Trim(txt or '')
            if txt == '' then return end
            netstream.Start('KPK::Announce:Create', {
                category = KPK._active.cat,
                channel  = KPK._active.ch,
                text     = txt
            })
        end)
    end

    local function openTasksCreateDialog(category)
        local fr = vgui.Create('DFrame') fr:SetTitle('Новая задача') fr:SetSize(460, 420) fr:Center() fr:MakePopup()
        local t1 = vgui.Create('DTextEntry', fr) t1:SetPos(12,36) t1:SetSize(436,28)  t1:SetText('Заголовок')
        local t2 = vgui.Create('DTextEntry', fr) t2:SetPos(12,68) t2:SetSize(436,230) t2:SetMultiline(true) t2:SetText('Описание')
        local t3 = vgui.Create('DTextEntry', fr) t3:SetPos(12,304) t3:SetSize(216,28) t3:SetText('SteamID исполнителя (опц.)')
        local t4 = vgui.Create('DTextEntry', fr) t4:SetPos(232,304) t4:SetSize(216,28) t4:SetText('Дедлайн UNIX (опц.)')
        local ok = vgui.Create('DButton', fr) ok:SetPos(12,340) ok:SetSize(436,28) ok:SetText('Создать')
        ok.DoClick = function()
            local title = string.Trim(t1:GetValue() or '')
            local desc  = string.Trim(t2:GetValue() or '')
            local sid   = string.Trim(t3:GetValue() or '')
            local dl    = tonumber(t4:GetValue() or 0) or 0
            if title == '' then return end
            netstream.Start('KPK::Tasks:Create', { category=category, title=title, description=desc, assignee_sid=sid, deadline=dl })
            fr:Close()
        end
    end

    local function openIntegrationsMenu()
        if not KPK._active then return end
        local cat, ch = KPK._active.cat, KPK._active.ch
        local menu = DermaMenu()

        local sub = menu:AddSubMenu('Интеграции гейммода')
        sub:AddOption('Служебное объявление…', function() openCreateAnnounceDialog() end):SetIcon('icon16/flag_yellow.png')
        sub:AddOption('Список подтвердивших…', function()
            Derma_StringRequest('Список подтвердивших', 'ID объявления (сообщения):', '', function(txt)
                local id = tonumber(txt or 0) or 0
                if id > 0 then netstream.Start('KPK::Announce:List', { message_id = id }) end
            end)
        end):SetIcon('icon16/group.png')

        local tmenu = menu:AddSubMenu('Задачи и отчётность')
        tmenu:AddOption('Открыть задачи категории', function()
            KPK._mode = 'tasks'
            netstream.Start('KPK::Tasks:List', { category = cat })
        end):SetIcon('icon16/table.png')
        tmenu:AddOption('Создать задачу…', function() openTasksCreateDialog(cat) end):SetIcon('icon16/add.png')
        tmenu:AddOption('Авто-отчёт по смене…', function() openAutoReportDialog() end):SetIcon('icon16/report.png')

        menu:AddSpacer()

        -- Админ-утилиты по текущему каналу
        local util = menu:AddSubMenu('Админ-утилиты канала')
        util:AddOption('Обновить канал', function() netstream.Start('KPK::Fetch', { category=cat, channel=ch }) end):SetIcon('icon16/arrow_refresh.png')

        local curPin = (pins[cat] or {})[ch]
        if curPin and curPin.message_id then
            util:AddOption('Снять закреп', function()
                netstream.Start('KPK::Pin:Clear', { category=cat, channel=ch })
            end):SetIcon('icon16/flag_red.png')
        end
        util:AddOption('Закрепить по ID…', function()
            Derma_StringRequest('Закрепить', 'Введите ID сообщения этого канала:', '', function(txt)
                local id = tonumber(txt or 0) or 0
                if id>0 then netstream.Start('KPK::Pin:Set', { category=cat, channel=ch, message_id=id }) end
            end)
        end):SetIcon('icon16/flag_green.png')

        util:AddSpacer()
        local subDel = util:AddSubMenu('Массовое удаление')
        subDel:AddOption('Удалить последние N…', function()
            Derma_StringRequest('Удалить последние N', 'Сколько последних сообщений удалить?', '50', function(n)
                n = tonumber(n or 0) or 0
                if n>0 then netstream.Start('KPK::Admin:BulkDelete', { category=cat, channel=ch, mode='last_n', n=n }) end
            end)
        end):SetIcon('icon16/delete.png')
        subDel:AddOption('Удалить старше D дней…', function()
            Derma_StringRequest('Удалить по возрасту', 'Старше скольки дней удалить?', '30', function(d)
                d = tonumber(d or 0) or 0
                if d>0 then netstream.Start('KPK::Admin:BulkDelete', { category=cat, channel=ch, mode='older_than_days', days=d }) end
            end)
        end):SetIcon('icon16/time_delete.png')
        subDel:AddOption('Удалить диапазон ID…', function()
            Derma_StringRequest('Диапазон ID', 'Формат: A-B (например 100-200)', '', function(s)
                local a,b = string.match(s or '', '^(%d+)%-(%d+)$')
                if a and b then netstream.Start('KPK::Admin:BulkDelete', { category=cat, channel=ch, mode='id_range', a=tonumber(a), b=tonumber(b) }) end
            end)
        end):SetIcon('icon16/text_columns.png')
        subDel:AddOption('Полная очистка канала…', function()
            Derma_Query('Удалить ВСЕ сообщения канала безвозвратно?', 'Подтверждение',
                'Да', function() netstream.Start('KPK::Admin:BulkDelete', { category=cat, channel=ch, mode='wipe_channel' }) end,
                'Отмена'
            )
        end):SetIcon('icon16/bin.png')

        menu:Open()
    end

    gearBtn.DoClick = function()
        if not isAdminLike then
            notification.AddLegacy('Недостаточно прав.', NOTIFY_ERROR, 3)
            surface.PlaySound('buttons/button10.wav')
            return
        end
        openIntegrationsMenu()
    end

    -- ПИН-БАР / список/формы
    local pinBar = TDLib('DPanel', right) pinBar:Dock(TOP) pinBar:SetTall(48) pinBar:ClearPaint()
    local list = TDLib('DScrollPanel', right) list:Dock(FILL) list:ClearPaint()
    list.OnMouseReleased = function(_, mc) if mc == MOUSE_RIGHT then openIntegrationsMenu() end end

    -- Полоса "Ответ на ..."
    local replyBar = TDLib('DPanel', right)
    replyBar:Dock(BOTTOM)
    replyBar:SetTall(0)
    replyBar:ClearPaint()
    local function updateReplyBar()
        if not IsValid(KPK.UI) then return end
        if not KPK._reply or not KPK._reply.id then replyBar:SetTall(0) replyBar:Clear() return end
        replyBar:SetTall(42)
        replyBar:Clear()
        replyBar:Background(Color(54,57,63))
        local txt = TDLib('DPanel', replyBar) txt:Dock(FILL) txt:ClearPaint()
        local stamp = KPK._reply.created_at and os.date('%d.%m %H:%M', tonumber(KPK._reply.created_at)) or ''
        txt:Text('Ответ на #'..tostring(KPK._reply.id)..'  ['..stamp..']  '..truncate(KPK._reply.content, 80), 'font_sans_18', Color(210,210,215), TEXT_ALIGN_LEFT, 10)
        local cancel = TDLib('DButton', replyBar) cancel:Dock(RIGHT) cancel:SetWide(42) cancel:ClearPaint(); btnNoText(cancel)
        cancel:Text('✖','font_sans_21', Color(255,255,255), TEXT_ALIGN_CENTER,0)
        cancel.DoClick = function() KPK._reply = nil; updateReplyBar() end
    end

    -- ===== Ввод (режим «Чаты») =====
    local inputRow = TDLib('DPanel', right)
    inputRow:Dock(BOTTOM)
    inputRow:SetTall(64)
    inputRow:ClearPaint()
    inputRow:Background(Color(54,57,63))

    local entry = vgui.Create('DTextEntry', inputRow)
    entry:Dock(FILL)
    entry:DockMargin(10,10,10,10)
    entry:SetDrawBackground(true)
    entry:SetPaintBackground(true)
    entry:SetTextColor(Color(230,230,230))
    entry:SetCursorColor(Color(230,230,230))
    entry:SetHighlightColor(Color(88,101,242))
    entry:SetFont('font_sans_18')
    entry:SetMultiline(true)
    entry:SetVerticalScrollbarEnabled(true)
    KPK._entry = entry

    entry._placeholder = 'Напишите сообщение…  (Enter — отправить, Shift+Enter — новая строка)'
    entry._showph = true
    entry.OnGetFocus = function(s) s._showph = false end
    entry.OnLoseFocus = function(s) if (string.Trim(s:GetValue() or '') == '') then s._showph = true end end
    entry.Paint = function(s,w,h)
        if KPK._mode ~= 'chat' then return end
        draw.RoundedBox(10,0,0,w,h,Color(64,68,75))
        if s._showph and (string.Trim(s:GetValue() or '') == '') then
            draw.SimpleText(s._placeholder, 'font_sans_16', 10, h/2, Color(190,190,190,160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        s:DrawTextEntryText(Color(230,230,230), Color(88,101,242), Color(230,230,230))
    end

    local sendBtn = TDLib('DButton', inputRow)
    sendBtn:Dock(RIGHT)
    sendBtn:SetWide(130)
    sendBtn:ClearPaint(); btnNoText(sendBtn)
    sendBtn:Text('Отправить', 'font_sans_18', Color(255,255,255))

    local function doSend()
        if KPK._mode ~= 'chat' then return end
        if not (IsValid(KPK.UI) and IsValid(entry)) then return end
        local txt = string.Trim(entry:GetValue() or '')
        if txt == '' or not KPK._active then return end
        netstream.Start('KPK::Post', {
            category = KPK._active.cat,
            channel  = KPK._active.ch,
            text     = txt,
            reply_to_id = KPK._reply and KPK._reply.id or nil
        })
        KPK._drafts[keyFor(KPK._active.cat, KPK._active.ch)] = ''
        entry:SetText('')
        entry._showph = true
        KPK._reply = nil
        updateReplyBar()
        inputRow:SetTall(64)
        inputRow:InvalidateLayout(true)
    end
    sendBtn.DoClick = doSend

    entry.OnKeyCodeTyped = function(s, key)
        if KPK._mode ~= 'chat' then return end
        if key == KEY_ENTER or key == KEY_PAD_ENTER then
            if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT) then
                s:InsertText("\n")
                timer.Simple(0, function() if IsValid(s) then s:RequestFocus() end end)
                return true
            else
                doSend()
                return true
            end
        end
    end

    -- Авто-рост поля (до 5 строк)
    local minTall, maxLines = 64, 5
    local function measureLines(text, font, maxw)
        surface.SetFont(font)
        local lines = 0
        local function count_line(str)
            if str == '' then return 1 end
            local cur, ln = '', 1
            for word in string.gmatch(str, '%S+%s*') do
                local test = cur .. word
                local tw = surface.GetTextSize(test)
                if tw > maxw and cur ~= '' then ln = ln + 1 cur = word else cur = test end
            end
            return ln
        end
        for l in string.gmatch((text or ''):gsub('\r\n','\n')..'\n', '([^\n]*)\n') do lines = lines + count_line(l or '') end
        return math.max(1, lines)
    end
    local function autoGrow()
        if not (IsValid(entry) and IsValid(inputRow)) then return end
        local w = entry:GetWide() - 20; if w < 50 then w = 50 end
        local lines = measureLines(entry:GetValue() or '', 'font_sans_18', w)
        local _, fh = surface.GetTextSize('Hg')
        local want = math.Clamp(20 + lines * (fh + 2), minTall - 8, 20 + maxLines * (fh + 2))
        inputRow:SetTall(math.max(minTall, math.floor(want))); inputRow:InvalidateLayout(true)
        entry._showph = (string.Trim(entry:GetValue() or '') == '') and not entry:HasFocus()
    end
    entry.OnValueChange = function()
        if KPK._mode ~= 'chat' then return end
        autoGrow()
        if KPK._active then
            local k = keyFor(KPK._active.cat, KPK._active.ch)
            KPK._drafts[k] = entry:GetValue() or ''
            if not KPK._draftSaveAt or KPK._draftSaveAt < CurTime() then
                KPK._draftSaveAt = CurTime() + 0.6
                timer.Create('KPK::DraftSave', 0.7, 1, function() file.Write(DRAFTS_FILE, util.TableToJSON(KPK._drafts or {}, true)) end)
            end
        end
    end
    entry.OnSizeChanged = function() timer.Simple(0, autoGrow) end
    right.OnSizeChanged = function() timer.Simple(0, autoGrow) end

    -- ===== Helpers =====
    local rowsCache = {} -- id -> {row, label, annBar}

    local function addMessage(p, highlightId, animated)
        if not (IsValid(KPK.UI) and IsValid(list)) then return end

        -- ===== особый вид для служебного объявления =====
        if tonumber(p.is_announce or 0) == 1 then
            local row = TDLib('DPanel', list) row:Dock(TOP) row:DockMargin(10,10,10,0) row:ClearPaint()
            if animated then row:SetAlpha(0) row:AlphaTo(255, 0.18, 0, nil) end
            row._msg = p

            local card = TDLib('DPanel', row) card:Dock(TOP) card:ClearPaint()
            card.Paint = function(s,w,h) draw.RoundedBox(12, 0,0,w,h, Color(54,57,63)) end

            -- шапка
            local head = TDLib('DPanel', card) head:Dock(TOP) head:SetTall(40) head:ClearPaint()
            head.Paint = function(s,w,h)
                draw.RoundedBoxEx(12,0,0,w,h, Color(64,68,75), true, true, false, false)
                draw.SimpleText('📢  Служебное объявление', 'font_sans_18', 12, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                local stamp = os.date('%d.%m %H:%M', tonumber(p.created_at or 0))
                draw.SimpleText(stamp, 'font_sans_16', w-12, h/2, Color(190,190,195), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            -- текст
            local body = vgui.Create('DLabel', card)
            body:Dock(TOP)
            body:DockMargin(12,10,12,10)
            body:SetFont('font_sans_18')
            body:SetTextColor(Color(230,230,230))
            body:SetWrap(true)
            body:SetAutoStretchVertical(true)
            body:SetText(tostring(p.content or ''))

            -- предпросмотр ссылки (если есть)
            local url = extractFirstUrl(tostring(p.content or ""))
            if url then buildLinkPreview(card, url) end

            -- панель действий
            local act = TDLib('DPanel', card) act:Dock(TOP) act:SetTall(44) act:DockMargin(12,0,12,12) act:ClearPaint()
            local okBtn = TDLib('DButton', act) okBtn:Dock(LEFT) okBtn:SetWide(150) okBtn:DockMargin(0,8,8,8) okBtn:ClearPaint()
            okBtn.Paint = function(s,w,h)
                local mine = KPK._annMine[tonumber(p.id) or 0]
                draw.RoundedBox(10,0,0,w,h, mine and Color(88,101,242) or Color(78,82,88))
                draw.SimpleText(mine and 'Прочитано' or 'Прочитал', 'font_sans_16', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            okBtn.DoClick = function()
                local mid = tonumber(p.id or 0); if mid<=0 then return end
                if KPK._annMine[mid] then return end
                netstream.Start('KPK::Announce:Confirm', { message_id = mid })
                KPK._annMine[mid] = true
                act:InvalidateLayout(true)
            end

            local cntBtn = TDLib('DButton', act) cntBtn:Dock(LEFT) cntBtn:SetWide(200) cntBtn:DockMargin(0,8,8,8) cntBtn:ClearPaint()
            cntBtn.Paint = function(s,w,h)
                draw.RoundedBox(10,0,0,w,h, Color(78,82,88))
                draw.SimpleText('Подтвердили: '..tostring(KPK._annCounts[tonumber(p.id) or 0] or 0),
                    'font_sans_16', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            cntBtn.DoClick = function()
                netstream.Start('KPK::Announce:List', { message_id = tonumber(p.id or 0) })
            end

            -- контекстное меню на карточке
            row.OnMouseReleased = function(s, mc)
                if mc ~= MOUSE_RIGHT then return end
                local menu = DermaMenu()
                if url then menu:AddOption('Открыть ссылку', function() gui.OpenURL(url) end):SetIcon('icon16/link.png') end
                local isOwner = (tostring(p.steam_id or '') == LocalPlayer():SteamID())
                local a = KPK._active and payload and payload.acl and payload.acl[KPK._active.cat] and payload.acl[KPK._active.cat][KPK._active.ch]
                local canMod = a and a.can_pin or (payload.profile and payload.profile.is_admin_like)

                if isOwner then
                    menu:AddOption('Редактировать…', function()
                        Derma_StringRequest('Редактирование', 'Измените текст объявления:', p.content or '', function(txt)
                            if string.Trim(txt or '') == '' then return end
                            netstream.Start('KPK::Edit', { id = tonumber(p.id or 0), text = txt })
                        end)
                    end):SetIcon('icon16/pencil.png')
                end

                if canMod and KPK._active then
                    local curPin = (pins[KPK._active.cat] or {})[KPK._active.ch]
                    if curPin and tonumber(curPin.message_id or 0) == tonumber(p.id or -1) then
                        menu:AddOption('Снять закреп', function()
                            netstream.Start('KPK::Pin:Clear', { category=KPK._active.cat, channel=KPK._active.ch })
                        end):SetIcon('icon16/flag_red.png')
                    else
                        menu:AddOption('Закрепить это сообщение', function()
                            netstream.Start('KPK::Pin:Set', { category=KPK._active.cat, channel=KPK._active.ch, message_id=tonumber(p.id or 0) })
                        end):SetIcon('icon16/flag_green.png')
                    end
                end

                if isOwner or canMod then
                    menu:AddOption('Удалить…', function()
                        Derma_Query('Удалить это объявление?', 'Подтверждение',
                            'Да', function() netstream.Start('KPK::Delete', { id = tonumber(p.id or 0) }) end,
                            'Отмена'
                        )
                    end):SetIcon('icon16/delete.png')
                end

                menu:AddSpacer()
                menu:AddOption('Скопировать ID', function() if p.id then SetClipboardText(tostring(p.id)) end end):SetIcon('icon16/tag.png')
                menu:Open()
            end

            row:SizeToChildren(false, true)
            return row
        end
        -- ===== конец особого вида =====

        -- обычные сообщения
        local row = TDLib('DPanel', list) row:Dock(TOP) row:SetTall(0) row:ClearPaint() row:DockMargin(10,8,10,0)
        if animated then row:SetAlpha(0) row:AlphaTo(255, 0.18, 0, nil) end
        row._msg = p

        local isMention = isMentionedForLocal(p.content or '', p.category)
        if isMention and animated then
            surface.PlaySound('friends/message.wav')
            row._blinkStart = CurTime()
            row.PaintOver = function(s,w,h)
                local t = CurTime() - (s._blinkStart or 0)
                if t < 5 then
                    local a = math.abs(math.sin(t * 5)) * 40 + 15
                    draw.RoundedBox(8,0,0,w,h, Color(255, 196, 0, a))
                end
            end
        end

        if tonumber(p.reply_to or 0) and tonumber(p.reply_to or 0) > 0 then
            local q = TDLib('DPanel', row) q:Dock(TOP) q:SetTall(32) q:ClearPaint()
            q.Paint = function(s,w,h)
                draw.RoundedBox(8,0,0,w,h, Color(64,68,75))
                surface.SetDrawColor(88,101,242, 120); surface.DrawRect(0,0,4,h)
            end
            local preview = p.reply_content or '[сообщение недоступно]'
            local stampR = p.reply_created_at and os.date('%d.%m %H:%M', tonumber(p.reply_created_at)) or ''
            local txtp = TDLib('DPanel', q) txtp:Dock(FILL) txtp:ClearPaint()
            txtp:Text('Ответ на #'..tostring(p.reply_to)..'  ['..stampR..']  '..truncate(preview, 80), 'font_sans_16', Color(210,210,215), TEXT_ALIGN_LEFT, 12)
            local jump = TDLib('DButton', q) jump:Dock(RIGHT) jump:SetWide(120) jump:ClearPaint()
            jump:Text('Перейти', 'font_sans_16', Color(255,255,255))
            jump.DoClick = function()
                netstream.Start('KPK::Fetch', { category = KPK._active.cat, channel = KPK._active.ch, before_id = tonumber(p.reply_to)+1 })
                KPK._highlightId = tonumber(p.reply_to)
            end
        end

        local label = TDLib('DLabel', row) label:Dock(TOP) label:ClearPaint()
        local stamp = os.date('%d.%m %H:%M', tonumber(p.created_at or 0))
        local editedSuffix = (p.edited_at and tonumber(p.edited_at) and '  (изменено)') or ''
        label:SetText(('[%s] %s%s'):format(stamp, tostring(p.content or ''), editedSuffix))
        label:SetFont('font_sans_18') label:SetTextColor(Color(230,230,230)) label:SizeToContentsY()

        if tonumber(p.id) == tonumber(highlightId) then
            row.Paint = function(s,w,h) draw.RoundedBox(8,0,0,w,h,Color(88,101,242,28)) end
        end

        local url = extractFirstUrl(tostring(p.content or ""))
        if url then buildLinkPreview(row, url) end

        row.OnMouseReleased = function(s, mc)
            if mc ~= MOUSE_RIGHT then return end
            local menu = DermaMenu()
            if url then menu:AddOption('Открыть ссылку', function() gui.OpenURL(url) end):SetIcon('icon16/link.png') end

            local isOwner = (tostring(p.steam_id or '') == LocalPlayer():SteamID())
            local a = KPK._active and payload and payload.acl and payload.acl[KPK._active.cat] and payload.acl[KPK._active.cat][KPK._active.ch]
            local canMod = a and a.can_pin or (payload.profile and payload.profile.is_admin_like)

            if isOwner then
                menu:AddOption('Редактировать…', function()
                    Derma_StringRequest('Редактирование', 'Измените текст сообщения:', p.content or '', function(txt)
                        if string.Trim(txt or '') == '' then return end
                        netstream.Start('KPK::Edit', { id = tonumber(p.id or 0), text = txt })
                    end)
                end):SetIcon('icon16/pencil.png')
            end

            menu:AddOption('Ответить', function()
                KPK._reply = { id = tonumber(p.id or 0), content = p.content, steam_id = p.steam_id, created_at = p.created_at }
                if KPK._entry and KPK._entry.RequestFocus then KPK._entry:RequestFocus() end
                if updateReplyBar then updateReplyBar() end
            end):SetIcon('icon16/arrow_turn_left.png')

            if canMod and KPK._active then
                local curPin = (pins[KPK._active.cat] or {})[KPK._active.ch]
                if curPin and tonumber(curPin.message_id or 0) == tonumber(p.id or -1) then
                    menu:AddOption('Снять закреп', function()
                        netstream.Start('KPK::Pin:Clear', { category=KPK._active.cat, channel=KPK._active.ch })
                    end):SetIcon('icon16/flag_red.png')
                else
                    menu:AddOption('Закрепить это сообщение', function()
                        netstream.Start('KPK::Pin:Set', { category=KPK._active.cat, channel=KPK._active.ch, message_id=tonumber(p.id or 0) })
                    end):SetIcon('icon16/flag_green.png')
                end
            end

            if isOwner or canMod then
                menu:AddOption('Удалить…', function()
                    Derma_Query('Удалить это сообщение?', 'Подтверждение',
                        'Да', function() netstream.Start('KPK::Delete', { id = tonumber(p.id or 0) }) end,
                        'Отмена')
                end):SetIcon('icon16/delete.png')
            end

            menu:AddSpacer()
            menu:AddOption('Скопировать ID', function() if p.id then SetClipboardText(tostring(p.id)) end end):SetIcon('icon16/tag.png')
            menu:AddOption('Скопировать текст', function() SetClipboardText(tostring(p.content or '')) end):SetIcon('icon16/page_white_text.png')
            menu:Open()
        end

        row:SizeToChildren(false, true)
        return row
    end

    local function computeMinIdAndStore(key, rowsDESC)
        local minId = 0
        if rowsDESC and rowsDESC[#rowsDESC] and rowsDESC[#rowsDESC].id then
            minId = tonumber(rowsDESC[#rowsDESC].id) or 0
        end
        KPK._minId[key] = minId
    end

    local function showMessages(rowsDESC, highlightId, opts)
        if not (IsValid(KPK.UI) and IsValid(list)) then return end
        opts = opts or {}
        local vbar = list:GetVBar()
        local prevTall = opts.prevCanvasTall or list:GetCanvas():GetTall()
        local prevScroll = opts.prevScroll or (IsValid(vbar) and vbar:GetScroll() or 0)

        list:Clear()
        for i = #rowsDESC, 1, -1 do addMessage(rowsDESC[i], highlightId, false) end
        list:InvalidateLayout(true)

        local canvasTall = list:GetCanvas():GetTall()
        if opts.keepPosition and IsValid(vbar) then
            local delta = math.max(0, canvasTall - prevTall)
            vbar:SetScroll(prevScroll + delta)
        else
            local maxScroll = math.max(0, canvasTall - list:GetTall())
            if IsValid(vbar) then vbar:SetScroll(maxScroll) end
        end
    end

    local function updateInputAccess()
        if not (IsValid(KPK.UI) and IsValid(entry) and IsValid(sendBtn)) then return end
        if KPK._mode ~= 'chat' then
            sendBtn:SetEnabled(false); entry:SetEnabled(false); entry._showph = true
            return
        end
        if not KPK._active then return end
        local a = acl[KPK._active.cat] and acl[KPK._active.cat][KPK._active.ch]
        local canPost = a and a.can_post
        sendBtn:SetEnabled(canPost == true)
        entry:SetEnabled(canPost == true)
        if not canPost then
            entry._placeholder = 'Нет прав на отправку в этот канал'
            entry._showph = true
        else
            entry._placeholder = 'Напишите сообщение…  (Enter — отправить, Shift+Enter — новая строка)'
        end
    end

    local function applyDraft(cat, ch)
        if not IsValid(entry) then return end
        local k = keyFor(cat, ch)
        local val = KPK._drafts[k] or ''
        entry:SetText(val)
        entry._showph = (string.Trim(val) == '')
        timer.Simple(0, function() if IsValid(entry) then entry:RequestFocus() entry:OnValueChange() end end)
    end

    local function requestOlder()
        if KPK._mode ~= 'chat' then return end
        if not KPK._active or not IsValid(KPK.UI) then return end
        if KPK._awaitOlderFor then return end
        if KPK._fetchCD > CurTime() then return end

        local key = keyFor(KPK._active.cat, KPK._active.ch)
        local minId = tonumber(KPK._minId[key] or 0)
        if not minId or minId <= 0 then return end

        local vbar = list:GetVBar()
        KPK._prevScroll[key] = IsValid(vbar) and vbar:GetScroll() or 0
        KPK._prevTall[key]   = list:GetCanvas():GetTall()

        KPK._awaitOlderFor = key
        KPK._fetchCD = CurTime() + 0.25
        netstream.Start('KPK::Fetch', { category = KPK._active.cat, channel = KPK._active.ch, before_id = minId })
    end

    local function bindAutoScroll()
        local vbar = list:GetVBar()
        if not IsValid(vbar) then return end
        vbar.Think = function(self)
            if not (IsValid(KPK.UI) and IsValid(list)) then return end
            if KPK._mode == 'chat' then
                if self:GetScroll() <= 4 then requestOlder() end
                local maxScroll = math.max(0, list:GetCanvas():GetTall() - list:GetTall())
                KPK._autoBottom = (self:GetScroll() >= (maxScroll - 64))
            end
        end
    end

    local function load(cat, ch, before, highlightId)
        if not IsValid(KPK.UI) then return end
        -- сохранить черновик прошлого канала
        if KPK._active and IsValid(entry) then
            KPK._drafts[keyFor(KPK._active.cat, KPK._active.ch)] = entry:GetValue() or ''
            file.Write(DRAFTS_FILE, util.TableToJSON(KPK._drafts or {}, true))
        end
        KPK._active = { cat = cat, ch = ch }
        KPK._reply = nil
        title:Text((cats[cat] and cats[cat].name or cat) .. ' # ' .. (ch or ''), 'font_sans_24', Color(255,255,255), TEXT_ALIGN_LEFT, 10)
        updateInputAccess()
        KPK._awaitOlderFor = nil
        netstream.Start('KPK::Fetch', { category = cat, channel = ch, before_id = before })
        KPK._highlightId = highlightId
        KPK._autoBottom = true
        applyDraft(cat, ch)
    end

    -- ===== NET-хуки: чат =====
    netstream.Hook('KPK::Fetch:OK', function(r)
        if not (IsValid(KPK.UI) and IsValid(list) and IsValid(pinBar)) then return end
        if not KPK._active then return end
        if r.category ~= KPK._active.cat or r.channel ~= KPK._active.ch then return end

        local key = keyFor(r.category, r.channel)
        local buf = KPK._buffers[key]

        -- объявления (счётчики)
        KPK._annCounts = KPK._annCounts or {}
        KPK._annMine   = KPK._annMine or {}
        if r.ann then
            for mid, c in pairs(r.ann.counts or {}) do KPK._annCounts[tonumber(mid)] = tonumber(c) or 0 end
            for mid, v in pairs(r.ann.mine or {}) do KPK._annMine[tonumber(mid)] = (v and true) or false end
        end

        if KPK._awaitOlderFor == key and istable(buf) then
            for _, row in ipairs(r.rows or {}) do table.insert(buf, row) end
            KPK._buffers[key] = buf
            local minId = 0; if buf[#buf] and buf[#buf].id then minId = tonumber(buf[#buf].id) or 0 end
            KPK._minId[key] = minId
            -- перерисовка без прыжка
            local vbar = list:GetVBar()
            local prevTall = KPK._prevTall[key] or list:GetCanvas():GetTall()
            local prevScroll = KPK._prevScroll[key] or 0

            list:Clear()
            for i = #buf, 1, -1 do addMessage(buf[i], KPK._highlightId, false) end
            list:InvalidateLayout(true)

            if IsValid(vbar) then
                local delta = math.max(0, list:GetCanvas():GetTall() - prevTall)
                vbar:SetScroll(prevScroll + delta)
            end
            KPK._awaitOlderFor = nil
        else
            KPK._buffers[key] = r.rows or {}
            local minId = 0; if KPK._buffers[key][#KPK._buffers[key]] and KPK._buffers[key][#KPK._buffers[key]].id then
                minId = tonumber(KPK._buffers[key][#KPK._buffers[key]].id) or 0
            end
            KPK._minId[key] = minId
            list:Clear()
            for i = #KPK._buffers[key], 1, -1 do addMessage(KPK._buffers[key][i], KPK._highlightId, false) end
            list:InvalidateLayout(true)
            bindAutoScroll()
        end

        -- ПИН-БАР
        pinBar:Clear()
        local pinfo = (pins[r.category] or {})[r.channel]
        if pinfo and pinfo.message_id then
            local icon = TDLib('DPanel', pinBar) icon:Dock(LEFT) icon:SetWide(32) icon:ClearPaint() icon:Text('📌','font_sans_24',Color(255,255,255),TEXT_ALIGN_CENTER,0)
            local txt = TDLib('DPanel', pinBar) txt:Dock(FILL) txt:ClearPaint()
            txt:Text('Есть закреплённое сообщение (ID '..pinfo.message_id..')', 'font_sans_18', Color(255,255,255), TEXT_ALIGN_LEFT, 10)
            local goBtn = TDLib('DButton', pinBar) goBtn:Dock(RIGHT) goBtn:SetWide(150) goBtn:ClearPaint(); btnNoText(goBtn)
            goBtn:Text('Перейти', 'font_sans_18', Color(255,255,255))
            goBtn.DoClick = function() if IsValid(KPK.UI) then load(r.category, r.channel, tonumber(pinfo.message_id)+1, tonumber(pinfo.message_id)) end end
        end
    end)

    netstream.Hook('KPK::Post:New', function(r)
        if KPK._mode ~= 'chat' then return end
        if not (IsValid(KPK.UI) and IsValid(list)) then return end
        if not KPK._active then return end
        if r.category ~= KPK._active.cat or r.channel ~= KPK._active.ch then return end

        local key = keyFor(r.category, r.channel)
        local buf = KPK._buffers[key] or {}
        table.insert(buf, 1, r.row or {})
        KPK._buffers[key] = buf

        if r.row and tonumber(r.row.is_announce or 0) == 1 then
            KPK._annCounts[tonumber(r.row.id)] = 0
            KPK._annMine[tonumber(r.row.id)] = false
        end

        addMessage(r.row or {}, nil, true)
        list:InvalidateLayout(true)

        local vbar = list:GetVBar()
        local canvasTall = list:GetCanvas():GetTall()
        local maxScroll = math.max(0, canvasTall - list:GetTall())
        if KPK._autoBottom and IsValid(vbar) then
            vbar:SetScroll(maxScroll)
        end
    end)

    netstream.Hook('KPK::Edit:OK', function(r)
        if KPK._active then
            netstream.Start('KPK::Fetch', { category = KPK._active.cat, channel = KPK._active.ch })
        end
    end)

    netstream.Hook('KPK::Edit:Denied', function(r)
        local msg = (r and r.reason) and tostring(r.reason) or 'Недоступно'
        notification.AddLegacy('Редактирование: '..msg, NOTIFY_ERROR, 3)
        surface.PlaySound('buttons/button10.wav')
    end)

    netstream.Hook('KPK::Delete:OK', function(r)
        if not (IsValid(KPK.UI) and IsValid(list)) then return end
        local id = tonumber(r.id or 0)
        local key = keyFor(r.category, r.channel)
        local buf = KPK._buffers[key]
        if istable(buf) then
            for i=#buf,1,-1 do if tonumber(buf[i].id or 0) == id then table.remove(buf, i) break end end
            KPK._buffers[key] = buf
            local minId = 0
            if buf[#buf] and buf[#buf].id then minId = tonumber(buf[#buf].id) or 0 end
            KPK._minId[key] = minId
        end
        if KPK._active and KPK._active.cat == r.category and KPK._active.ch == r.channel then
            netstream.Start('KPK::Fetch', { category = r.category, channel = r.channel, before_id = KPK._minId[key] or 0 })
        end
    end)

    netstream.Hook('KPK::Pin:Update', function(r)
        if not IsValid(KPK.UI) then return end
        if KPK._active and KPK._active.cat == r.category and KPK._active.ch == r.channel then
            netstream.Start('KPK::Fetch', { category = r.category, channel = r.channel, before_id = KPK._minId[keyFor(r.category, r.channel)] or 0 })
        end
        pins[r.category] = pins[r.category] or {}
        pins[r.category][r.channel] = r.pin
    end)

    netstream.Hook('KPK::Channel:Dirty', function(r)
        if not IsValid(KPK.UI) then return end
        if not r or not r.category or not r.channel then return end
        if KPK._active and KPK._active.cat == r.category and KPK._active.ch == r.channel then
            netstream.Start('KPK::Fetch', { category = r.category, channel = r.channel })
        end
    end)

    netstream.Hook('KPK::Announce:Update', function(r)
        local id = tonumber(r.message_id or 0); if id<=0 then return end
        KPK._annCounts[id] = tonumber(r.count or 0) or 0
    end)

    netstream.Hook('KPK::Announce:List:OK', function(r)
        local rows = r.rows or {}
        local txt = ''
        for _, v in ipairs(rows) do
            local t = v.confirmed_at and os.date('%d.%m %H:%M', tonumber(v.confirmed_at)) or ''
            txt = txt .. string.format('%s  —  %s\n', v.name or v.steam_id or '???', t)
        end
        if txt == '' then txt = 'Пока никто не подтвердил.' end
        Derma_Message(txt, 'Подтвердившие чтение', 'OK')
    end)

    -- Левое меню
    local function drawCats()
        if not IsValid(KPK.UI) then return end
        catsScroll:Clear()

        if table_count(cats) == 0 then
            local empty = TDLib('DPanel', catsScroll)
            empty:Dock(FILL) empty:ClearPaint()
            empty:Text('Нет доступа к категориям', 'font_sans_21', Color(200,200,200), TEXT_ALIGN_CENTER, 0)
            return
        end

        local function loadWrap(catId, chKey) return function()
            if IsValid(KPK.UI) then load(catId, chKey, nil) end
        end end

        for catId, def in pairs(cats) do
            local block = TDLib('DPanel', catsScroll) block:Dock(TOP) block:SetTall(30) block:ClearPaint()
            block:Text(def.name or catId, 'font_sans_21', Color(200,200,200), TEXT_ALIGN_LEFT, 8)
            for _, ch in ipairs(def.channels or {}) do
                local btn = TDLib('DButton', catsScroll)
                btn:Dock(TOP) btn:SetTall(36) btn:ClearPaint() btn:DockMargin(10,6,10,0) btn.Text = ch.name; btnNoText(btn)
                btn.Paint = function(s,w,h)
                    local act = (KPK._active and KPK._active.cat == catId and KPK._active.ch == ch.key)
                    draw.RoundedBox(10,0,0,w,h, act and Color(88,101,242) or Color(47,49,54))
                    draw.SimpleText(s.Text, 'font_sans_18', 14, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                btn.DoClick = loadWrap(catId, ch.key)
            end
        end
    end

    drawCats()
    for catId, def in pairs(cats) do
        if (def.channels or {})[1] then load(catId, def.channels[1].key) break end
    end

    -- ===== Режим «Задачи» =====
    local function renderTasks(category, tasks)
        list:Clear()
        pinBar:Clear()

        local top = TDLib('DPanel', pinBar) top:Dock(FILL) top:ClearPaint()
        local canManage = payload.profile and payload.profile.is_admin_like

        local createBtn = TDLib('DButton', top)
        createBtn:Dock(LEFT) createBtn:SetWide(170) createBtn:DockMargin(10,8,10,8) createBtn:ClearPaint(); btnNoText(createBtn)
        createBtn.Paint = function(s,w,h)
            draw.RoundedBox(10,0,0,w,h, Color(88,101,242))
            draw.SimpleText('Создать задачу', 'font_sans_18', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        createBtn:SetVisible(canManage)
        createBtn.DoClick = function()
            openTasksCreateDialog(category)
        end

        local canvas = vgui.Create('DIconLayout', list)
        canvas:Dock(FILL) canvas:SetSpaceX(10) canvas:SetSpaceY(10)
        local function addCard(t)
            local pnl = vgui.Create('DPanel', canvas) pnl:SetSize(380, 170)
            pnl.Paint = function(s,w,h) draw.RoundedBox(12,0,0,w,h, Color(47,49,54)) end
            local ttl = vgui.Create('DLabel', pnl) ttl:SetPos(12,10) ttl:SetSize(356, 24) ttl:SetFont('font_sans_21')
            ttl:SetText(t.title or ('Задача #'..tostring(t.id)))
            local who = vgui.Create('DLabel', pnl) who:SetPos(12,38) who:SetSize(356,20) who:SetFont('font_sans_16')
            local ass = t.assignee_name ~= '' and t.assignee_name or (t.assignee_sid or 'не назначен')
            who:SetText('Исполнитель: '..(ass or '—'))
            local st  = vgui.Create('DLabel', pnl) st:SetPos(12,60) st:SetSize(356,20) st:SetFont('font_sans_16')
            st:SetText('Статус: '..(t.status or 'open'))
            local dl  = vgui.Create('DLabel', pnl) dl:SetPos(12,82) dl:SetSize(356,20) dl:SetFont('font_sans_16')
            dl:SetText('Дедлайн: '..(tonumber(t.deadline or 0) > 0 and os.date('%d.%m %H:%M', tonumber(t.deadline)) or '—'))

            local bRow = vgui.Create('DPanel', pnl) bRow:SetPos(10, 110) bRow:SetSize(360, 44); bRow.Paint = function() end
            local function mkBtn(name, cb)
                local b = vgui.Create('DButton', bRow) b:SetSize(110, 32); b:SetText('')
                b.Paint = function(s,w,h) draw.RoundedBox(10,0,0,w,h, Color(64,68,75)); draw.SimpleText(name,'font_sans_16',w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
                b.DoClick = cb
                return b
            end

            local meIsAssignee = (t.assignee_sid or '') == LocalPlayer():SteamID()
            local amAdmin = isAdminLike
            local x = 0
            local function place(b) b:SetPos(x, 6); x = x + 118 end

            if amAdmin then place(mkBtn('Назначить себя', function()
                netstream.Start('KPK::Tasks:Update', { id=t.id, assignee_sid=LocalPlayer():SteamID() })
            end)) end

            if (meIsAssignee or amAdmin) then
                place(mkBtn('В работе', function() netstream.Start('KPK::Tasks:Update', { id=t.id, status='in_progress' }) end))
                place(mkBtn('Готово',    function() netstream.Start('KPK::Tasks:Update', { id=t.id, status='done' }) end))
            end

            if amAdmin then
                place(mkBtn('Удалить', function()
                    Derma_Query('Точно удалить задачу #'..tostring(t.id)..' ?', 'Подтверждение',
                        'Да', function() netstream.Start('KPK::Tasks:Delete', { id=t.id }) end,
                        'Отмена')
                end))
            end

            return pnl
        end

        for _, t in ipairs(tasks or {}) do addCard(t) end
    end

    -- ===== NET-хуки: задачи =====
    netstream.Hook('KPK::Tasks:List:OK', function(r)
        if not (IsValid(KPK.UI) and KPK._mode == 'tasks') then return end
        if not KPK._active or r.category ~= KPK._active.cat then return end
        KPK._tasks[r.category] = r.tasks or {}
        renderTasks(r.category, KPK._tasks[r.category])
    end)

    netstream.Hook('KPK::Tasks:Updated', function(r)
        if KPK._active and KPK._mode == 'tasks' and r.category == KPK._active.cat then
            netstream.Start('KPK::Tasks:List', { category = KPK._active.cat })
        end
    end)

    -- ===== Быстрая кнопка авто-отчёта =====
    local reportBtn = TDLib('DButton', title)
    reportBtn:Dock(RIGHT) reportBtn:SetWide(170) reportBtn:DockMargin(0,10,10,10) reportBtn:ClearPaint(); btnNoText(reportBtn)
    reportBtn.Paint = function(s,w,h)
        local show = (KPK._mode == 'chat' and KPK._active and KPK._active.ch == 'reports')
        if not show then return end
        draw.RoundedBox(10,0,0,w,h, Color(88,101,242))
        draw.SimpleText('Авто-отчёт', 'font_sans_18', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    reportBtn.DoClick = function() openAutoReportDialog() end

    -- Видимость ряда элементов
    right.Think = function()
        inputRow:SetVisible(KPK._mode == 'chat')
        replyBar:SetVisible(KPK._mode == 'chat')
    end
end)

concommand.Add('kpk_open', OpenKPK)
