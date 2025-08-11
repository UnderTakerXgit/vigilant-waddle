-- Shared permission helpers for KPK
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK = NextRP.KPK
local function CFG() return (NextRP.KPK and NextRP.KPK.Config) or {} end

-- Fetch job table for player
function KPK.GetPlayerJob(ply)
    if not IsValid(ply) then return end
    return NextRP.GetJob and NextRP.GetJob(ply:Team()) or nil
end

-- Convenience wrapper returning job id
function KPK.GetPlayerJobId(ply)
    local job = KPK.GetPlayerJob(ply)
    return job and job.id or nil
end

-- Check if player has whitelist in current job/rank
function KPK.HasWhitelist(ply)
    if not IsValid(ply) then return false end
    if ply.IsAdmin and ply:IsAdmin() then return true end
    local job = KPK.GetPlayerJob(ply)
    if not job or not job.ranks then return false end
    local rank = ply.GetRank and ply:GetRank() or nil
    if rank == nil then return false end
    local r = job.ranks[rank] or job.ranks[tostring(rank)] or job.ranks[tonumber(rank)]
    return istable(r) and r.whitelist == true
end

-- Can player view a category?
function KPK.CanSeeCategory(ply, catId)
    local jid = KPK.GetPlayerJobId(ply)
    if not jid then return false end
    if (CFG().testing_admin_access and ply:IsAdmin()) then return true end
    if jid == 'cmd' then return true end
    return jid == catId
end

-- Can player post to given channel?
function KPK.CanPostToChannel(ply, catId, channelDef)
    if not KPK.CanSeeCategory(ply, catId) then return false end
    if not channelDef or not channelDef.post then return false end
    if KPK.GetPlayerJobId(ply) == 'cmd' or (CFG().testing_admin_access and ply:IsAdmin()) then
        return true
    end
    if channelDef.post == 'all' then return true end
    if channelDef.post == 'whitelist_only' then return KPK.HasWhitelist(ply) end
    return false
end

-- Can player pin messages in channel?
function KPK.CanPinInChannel(ply, catId, channelDef)
    if not KPK.CanSeeCategory(ply, catId) then return false end
    if not channelDef or channelDef.can_pin ~= true then return false end
    return KPK.HasWhitelist(ply) or (KPK.GetPlayerJobId(ply) == 'cmd') or (CFG().testing_admin_access and ply:IsAdmin())
end
