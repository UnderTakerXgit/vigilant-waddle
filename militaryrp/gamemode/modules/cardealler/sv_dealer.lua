-- Спавн диллера на запуске сервера/клинапе
local function SpawnDealers()
    local dealersInfo = file.Read('dealers.txt', 'DATA')
    if dealersInfo == nil then
        file.Write('dealers.txt', '[]')
        print('[NextRP] Создан файл для спавнера техники!')
        return 
    end
    
    dealersInfo = util.JSONToTable(dealersInfo)

    for k, v in pairs(dealersInfo) do
        -- Проверка карты
        if k ~= game.GetMap() then continue end

        for kk, vv in pairs(v) do 
        -- Проверка настроек диллера
            if not vv.pos then continue end
            print 'pos'
            if not vv.ang then continue end
            print 'ang'
            if not vv.platforms then continue end
            print 'platforms'
            if not vv.faction then continue end
            print 'faction'
            if not vv.vehs then continue end
            print 'vehs'

            

            local dealer = ents.Create('nextrp_carspawner')
            if IsValid(dealer) then
                dealer:SetPos(vv.pos)
                dealer:SetAngles(vv.ang)

                dealer:Spawn()

                dealer:SpawnPlatforms(vv.platforms)
                dealer.Faction = vv.faction
                dealer.Vehicles = vv.vehs

                
            end

            PrintTable(dealer.Vehicles)
        end
    end

    if not file.Exists('cars.txt', 'DATA') then
        file.Write('cars.txt', '[]')
        print('Created cars file!')
    end

    local cars = util.JSONToTable(file.Read('cars.txt', 'DATA'))
    NextRPCarList = cars
end

hook.Add('InitPostEntity', 'NextRP::SpawnCarDealers', SpawnDealers)
hook.Add('PostCleanupMap', 'NextRP::SpawnCarDealers', SpawnDealers)

netstream.Hook('NextRP::SaveDealers', function(pPlayer)
    if not pPlayer:IsSuperAdmin() then return end

    local dealers = ents.FindByClass('nextrp_carspawner')

    local dealersInfo = file.Read('dealers.txt', 'DATA')
    if dealersInfo == nil then
        file.Write('dealers.txt', '[]')
        print('[NextRP] Создан файл для спавнера техники!')
        return 
    end
    
    dealersInfo = util.JSONToTable(dealersInfo)

    dealersInfo[game.GetMap()] = {}

    for k, v in pairs(dealers) do
        local index = #dealersInfo[game.GetMap()] + 1

        dealersInfo[game.GetMap()][index] = {
            pos = v:GetPos(),
            ang = v:GetAngles(),
            platforms = v:GetPlatforms(),
            faction = v.Faction,
            vehs = v.Vehicles
        }
    end

    file.Write('dealers.txt', util.TableToJSON(dealersInfo))
end)