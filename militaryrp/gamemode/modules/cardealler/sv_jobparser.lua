NextRPCarList = NextRPCarList or {}

netstream.Hook('NextRP::VehUpdate', function(pPlayer, tData)
    if not pPlayer:IsSuperAdmin() then return end

    if not file.Exists('cars.txt', 'DATA') then
        file.Write('cars.txt', '[]')
        print('Created cars file!')
    end

    local cars = util.JSONToTable(file.Read('cars.txt', 'DATA'))

    local find = false
    local findEntry = {}

    for k, v in pairs(cars) do
        if v.class == tData.class then
            find = true
        
            findEntry = k
            break 
        end
    end

    if find then
        cars[findEntry] = tData
    else
        cars[#cars + 1] = tData
    end

    file.Write('cars.txt', util.TableToJSON(cars, true))

    pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Транспорт сохранён в БД.')
    NextRPCarList = cars
end)

netstream.Hook('NextRP::GetVeh', function(pPlayer, vehClass, vehEnt)
    if not pPlayer:IsSuperAdmin() then return end 

    if not file.Exists('cars.txt', 'DATA') then
        file.Write('cars.txt', '[]')
        print('Created cars file!')
    end

    local cars = util.JSONToTable(file.Read('cars.txt', 'DATA'))

    local find = false
    local findEntry = {}

    for k, v in pairs(cars) do
        if v.class == vehClass then
            find = true
        
            findEntry = v
            break 
        end
    end

    if find then
        netstream.Start(pPlayer, 'NextRP::GetVeh', findEntry, vehEnt)
    else
        netstream.Start(pPlayer, 'NextRP::GetVeh', nil, vehEnt)
    end
    NextRPCarList = cars
end)

function NextRP:GetAvaibleCars(pPlayer)
    local c = NextRPCarList
    local ac = {}

    for k, v in pairs(c) do
        local find = false

        if not istable(v) then continue end
        if not v.permisions then continue end
        if not v.permisions[pPlayer:getJobTable().id] then continue end
        if v.permisions[pPlayer:getJobTable().id].permisions[pPlayer:GetRank()] then find = true end

        if not find then
            for kk, vv in pairs(pPlayer:GetNVar('nrp_charflags')) do
                if v.permisions[pPlayer:getJobTable().id].permisions[k] then find = true end
            end
        end

        if find then
            ac[#ac+1] = v
        end
    end
    
    return ac
end