-- Mention detection to highlight messages addressing the local player
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK = NextRP.KPK

local function sanitize(s)
    s = tostring(s or '')
    return string.Trim(string.lower(s))
end

function KPK.IsMentionedForLocal(text, catId)
    text = sanitize(text or '')
    if text == '' then return false end
    local lp = LocalPlayer()
    local nick = sanitize(lp:Nick())
    local fullname = sanitize(lp:GetNVar('nrp_fullname') or '')
    local callsign = sanitize(lp:GetNVar('nrp_nickname') or '')
    local rpid = sanitize(lp:GetNVar('nrp_rpid') or '')
    local jid = NextRP.KPK.GetPlayerJobId and (NextRP.KPK.GetPlayerJobId(lp) or '') or ''
    local jidL = sanitize(jid)
    local function hasToken(tok)
        if tok == '' then return false end
        return text:find('@'..tok,1,true) or (tok:sub(1,1)=='#' and text:find(tok,1,true))
    end
    if hasToken(nick) or hasToken(fullname) or hasToken(callsign) or (rpid ~= '' and hasToken('#'..rpid)) then return true end
    if hasToken(jidL) or hasToken(catId or '') or hasToken('all') or hasToken('here') then return true end
    return false
end
