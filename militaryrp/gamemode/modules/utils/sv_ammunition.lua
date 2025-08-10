netstream.Hook('NextRP::AmmunitionWeps', function(pPlayer, sWep)
    local weps = pPlayer.ammunitionweps

    pPlayer.WeaponTimers = pPlayer.WeaponTimers or {}
    pPlayer.WeaponTimers[sWep] = pPlayer.WeaponTimers[sWep] or CurTime() - 1

    if table.HasValue(weps.ammunition, sWep) or table.HasValue(weps.default, sWep) then
        if pPlayer:HasWeapon(sWep) then
            pPlayer:StripWeapon(sWep)
            pPlayer.WeaponTimers[sWep] = CurTime() + 20
        else
            if pPlayer.WeaponTimers[sWep] < CurTime() then
                pPlayer:Give(sWep)

                if sWep == 'fas2_ifak' then
                    pPlayer:GiveAmmo(11, 'Bandages')
                    pPlayer:GiveAmmo(17, 'Quikclots')
                    pPlayer:GiveAmmo(13, 'Hemostats')
                end
            else
                pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вам нужно подождать ещё ', Color(71, 141, 255), tostring(math.Round(pPlayer.WeaponTimers[sWep] - CurTime())), color_white, ' секунд, что-бы получить это оружие/экипировку!')
            end
        end
    end
end)

hook.Add('PlayerDeath', 'NextRP::ResetWepsTimers', function(pPlayer)
    pPlayer.WeaponTimers = {}
end)