hook.Add('PlayerCanHearPlayersVoice', 'NextRP::RadioHook', function(l, t)
    if l:GetNVar('radio_frequency') == t:GetNVar('radio_frequency') and t:GetNVar('radio_mic') and l:GetNVar('radio_speaker') then
        return true, false 
    end
end)

hook.Add('NextRP::PlayerFullLoad', 'NextRP::RadioInit', function(pPlayer)
    pPlayer:SetNVar('radio_frequency', tostring(math.random(1, 300))..'.'..tostring(math.random(0, 9)))
    pPlayer:SetNVar('radio_speaker', false)
    pPlayer:SetNVar('radio_mic', false)

    pPlayer:SetNVar('radio_key', pPlayer:GetPData('radio_key', KEY_J))
end)

netstream.Hook('NextRP::RadioKey', function(pPlayer, key)
    pPlayer:SetPData('radio_key', key)
    pPlayer:SetNVar('radio_key', key)
end)

