local pMeta = FindMetaTable('Player')

local oldName = pMeta.OldName or pMeta.Name
local oldNick = pMeta.OldName or pMeta.Nick

function pMeta:OldName()
    return oldName(self)
end

function pMeta:Name()
    return self:GetNVar('nrp_rpname') or self:OldName()
end

function pMeta:Nick1()
    return self:GetNVar('nrp_nickname') or self:OldName()
end

function pMeta:Nick()
    return self:FullName()
end

function pMeta:FullName()
    return self:GetNVar('nrp_fullname') or self:OldName()
end

function pMeta:Faction()
    return self:GetNVar('nrp_faction') or 1
end