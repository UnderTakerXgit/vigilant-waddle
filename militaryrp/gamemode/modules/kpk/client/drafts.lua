-- Draft management: load and save unsent messages between sessions
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK = NextRP.KPK

local DRAFTS_FILE = 'kpk_drafts.txt'

function KPK.LoadDrafts()
    if file.Exists(DRAFTS_FILE, 'DATA') then
        local ok, tbl = pcall(util.JSONToTable, file.Read(DRAFTS_FILE, 'DATA') or '{}')
        if ok and istable(tbl) then KPK._drafts = tbl return end
    end
    KPK._drafts = {}
end

function KPK.SaveDrafts()
    file.Write(DRAFTS_FILE, util.TableToJSON(KPK._drafts or {}, true))
end
