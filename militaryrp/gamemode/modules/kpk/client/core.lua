-- Client core for KPK: shared state and small helpers
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK = NextRP.KPK

-- Shortcut to config table
local function CFG() return (NextRP.KPK and NextRP.KPK.Config) or {} end
KPK.CFG = CFG

-- Persistent client state used across files
KPK.UI = KPK.UI or nil
KPK._buffers = KPK._buffers or {}   -- key "cat/ch" -> rows (DESC: new at start)
KPK._minId   = KPK._minId   or {}   -- key -> min id in buffer
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

-- Helper to build buffer key
function KPK.KeyFor(cat, ch)
    return tostring(cat or '') .. '/' .. tostring(ch or '')
end

-- Count table entries
function KPK.TableCount(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

-- Truncate string for UI
function KPK.Truncate(s, n)
    s = tostring(s or '')
    if #s > n then return string.sub(s,1,n-1)..'…' end
    return s
end

-- Remove text from button widgets
function KPK.BtnNoText(b)
    if b and b.SetText then b:SetText('') end
    return b
end
