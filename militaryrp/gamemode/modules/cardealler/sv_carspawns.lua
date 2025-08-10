netstream.Hook('NextRP::SpawnCar', function(pPlayer, eSpawner, sClass, iSkin, tBodygroups)

    if IsValid(pPlayer.SpawnedVeh) then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете вызвать более одной единицы техники!') return end

    local avaibleVehs = NextRP:GetAvaibleCars(pPlayer)

    local can = false

    for k, v in pairs(avaibleVehs) do
        if v.class == sClass then can = true break end
    end

    if not can then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'У вас нет доступа к этому транспорту!') return end

    local findedPlatform = nil

    for k, platform in pairs(eSpawner.Platforms) do
        local pPos = platform:GetPos()
        local pFinalPos = pPos + Vector(0, 0, 1000)

        local tr = util.TraceLine({
            start = pPos,
            endpos = pFinalPos,
            filter = platform,
            ignoreworld = true
        })

        if not tr.Hit then
            if not IsValid(tr.Entity) then findedPlatform = platform break end
        end
    end

    if IsValid(findedPlatform) then        
        local Veh = ents.Create(sClass)
        if not IsValid(Veh) then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Что-то не так с транспортом! Обратитесь к тех. администратору!')
            return 
        end

        Veh:SetPos(findedPlatform:GetPos() + Vector(0, 0, 100))
        Veh:SetAngles(findedPlatform:GetAngles())

        Veh:SetSkin(iSkin)

        for k, v in pairs(tBodygroups) do
            Veh:SetBodygroup(k, v)
        end

        Veh:Spawn()

        pPlayer.SpawnedVeh = Veh
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Невозможно найти свободное место! Попробуйте позже.')
    end
end)

netstream.Hook('NextRP::ReturnCar', function(pPlayer)

    if not IsValid(pPlayer.SpawnedVeh) then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не вызывали технику!') return end

    pPlayer.SpawnedVeh:Remove()
    pPlayer.SpawnedVeh = nil

    pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы вернули технику!')
end)