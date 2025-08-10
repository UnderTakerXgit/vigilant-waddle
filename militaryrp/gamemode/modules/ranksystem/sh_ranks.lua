local pMeta = FindMetaTable('Player')

function pMeta:GetRank()
    return self:GetNVar('nrp_rank')
end

function pMeta:GetNumber()
    return self:GetNVar('nrp_rpid')
end

function pMeta:GetFullRank()
    local rank = self:GetNVar('nrp_rank')
    local jt = self:getJobTable()

    if rank == false then return '' end
    if jt == false then return '' end
    if not istable(jt.ranks[rank]) then return '' end
    return jt.ranks[rank].fullRank
end

function pMeta:GetName()
    return self:GetNVar('nrp_name')
end

function pMeta:GetSurname()
    return self:GetNVar('nrp_surname')
end

function pMeta:GetNickname()
    return self:GetNVar('nrp_nickname')
end

function NextRP.Ranks:Can(pPlayer, pTarget)
    local playerRank = pPlayer:GetRank() or "Неизвестно"
    local targetRank = pTarget:GetRank()

    if pPlayer:IsAdmin() then return true end

        --if pPlayer:Team() ~= pTarget:Team() then 
            --if SERVER then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете изменять этого персонажа!') end
            --return false
        --end

    local isCommander = pPlayer:getJobTable().ranks[playerRank].whitelist
    local isExsists = pTarget:getJobTable().ranks[targetRank] and true or false

    if isCommander and isExsists then
        return true
    end

    if SERVER then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете изменять этого персонажа!') end
    return false 
end