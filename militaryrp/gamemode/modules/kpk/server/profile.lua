-- Track playtime of players for KPK profiles
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK  = NextRP.KPK
local function now() return os.time() end

local function ensureProfileRow(ply)
    local mysql = MySQLite.isMySQL and MySQLite.isMySQL() or false
    local sql
    if mysql then
        sql = 'INSERT IGNORE INTO kpk_profiles(steam_id, playtime) VALUES(' ..
              MySQLite.SQLStr(ply:SteamID()) .. ', 0);'
    else
        sql = 'INSERT OR IGNORE INTO kpk_profiles(steam_id, playtime) VALUES(' ..
              MySQLite.SQLStr(ply:SteamID()) .. ', 0);'
    end
    MySQLite.query(sql)
end

hook.Add('PlayerInitialSpawn', 'KPK::ProfileStart', function(ply)
    ensureProfileRow(ply)
    ply._kpkSessionStart = now()
end)

hook.Add('PlayerDisconnected', 'KPK::ProfileSave', function(ply)
    if not ply._kpkSessionStart then return end
    local add = math.max(0, now() - (ply._kpkSessionStart or now()))
    MySQLite.query('UPDATE kpk_profiles SET playtime = playtime + ' .. add ..
        ' WHERE steam_id = ' .. MySQLite.SQLStr(ply:SteamID()) .. ';')
end)
