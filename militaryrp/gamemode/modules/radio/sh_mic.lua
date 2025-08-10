local pMeta = FindMetaTable('Player')

function pMeta:SetFrequency(sValue)
    if tonumber(sValue) == nil then return end
    if tonumber(sValue) <= 0 then return end

    sValue = string.Replace(sValue, ',', '.')
    sValue = tonumber(sValue)
    sValue = math.Round(sValue, 1)
    sValue = tostring(sValue)

    if CLIENT then
        if self ~= LocalPlayer() then return end
        netstream.Start('NextRP::SetFrequency', sValue)
    else
        self:SetNVar('radio_frequency', sValue)
    end
end

function pMeta:GetFrequency()
    return self:GetNVar('radio_frequency', sValue)
end

netstream.Hook('NextRP::SetFrequency', function(pPlayer, sValue)
    pPlayer:SetFrequency(sValue)
end)

function pMeta:SetSpeaker(bToggle)
    if CLIENT then
        if self ~= LocalPlayer() then return end
        netstream.Start('NextRP::SetSpeaker', bToggle)
    else
        self:SetNVar('radio_speaker', bToggle)
    end
end

function pMeta:GetSpeaker()
    return self:GetNVar('radio_speaker') or false
end

netstream.Hook('NextRP::SetSpeaker', function(pPlayer, bToggle)
    pPlayer:SetSpeaker(bToggle)
end)


hook.Add('PlayerButtonDown', 'NextRP::RadioMicOn', function(pPlayer, iKey)   
    if iKey == tonumber(pPlayer:GetNVar('radio_key')) then
        if SERVER then
            pPlayer:SetNVar('radio_mic', true, NETWORK_PROTOCOL_PUBLIC)
        else
			permissions.EnableVoiceChat( true )
        end        
    end
end)

hook.Add('PlayerButtonUp', 'NextRP::RadioMicOn', function(pPlayer, iKey)
    if iKey == tonumber(pPlayer:GetNVar('radio_key')) then
        if SERVER then 
            pPlayer:SetNVar('radio_mic', false, NETWORK_PROTOCOL_PUBLIC)
        else
			permissions.EnableVoiceChat( false )
        end 
    end
end)
