-- Handling of URL detection and preview rendering
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK = NextRP.KPK

local function isImageUrl(url)
    url = string.lower(url or '')
    return url:find('%.png$') or url:find('%.jpe?g$') or url:find('%.gif$') or url:find('%.webp$')
end

local function parseYouTubeId(url)
    return string.match(url or '', 'youtu%.be/([%w%-%_]+)') or string.match(url or '', '[%?&]v=([%w%-%_]+)')
end

local function urlHost(u)
    return string.match(u or '', '^https?://([^/%?#:]+)') or 'link'
end

function KPK.ExtractFirstUrl(text)
    if not text or text == '' then return nil end
    local url = string.match(text, '(https?://[%w%-%._%?%.:/%+=&#%%@~]+)')
    if not url then return nil end
    url = string.gsub(url, '[%.,%)%]%}]+$', '')
    return url
end

function KPK.BuildLinkPreview(parent, url)
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
        local title = string.match(body or '', '<title>(.-)</title>')
        if title then title = (title:gsub('%s+', ' ')):Trim() end
        if title and title ~= '' then ttl:SetText(KPK.Truncate(title, 120)) end
    end)
    wrap.OnMouseReleased = function(_, mc) if mc == MOUSE_LEFT then gui.OpenURL(url) end end
    return wrap
end
