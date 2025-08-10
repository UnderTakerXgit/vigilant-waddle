function NextRP.Utils.IsAdmin(pPlayer)
    return NextRP.Config.Admins[pPlayer:GetUserGroup()] or false
end

local pMeta = FindMetaTable('Player')

local oldIsAdmin = pMeta.oldIsAdmin

function pMeta:IsAdmin()
    return NextRP.Utils.IsAdmin(self)
end