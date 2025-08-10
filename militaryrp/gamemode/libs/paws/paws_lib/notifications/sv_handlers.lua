local function Handler(_, sender)
    local ply = net.ReadEntity()
    local data = net.ReadData(255)

    -- net.Start('Paws.Lib.Notify')
    --     net.WriteData(data, 255)
    -- net.Send(ply)

    for k,v in ipairs(player.GetHumans()) do
        if v:IsAdmin() then
            PAW_MODULE('lib'):SendMessage(v, 0, Color(255,0,0), sender:Name(), ' попытался проникнуть в луа, но удача мамкиного хакера отвернулась от него.')

            PAW_MODULE('lib'):SendConsoleMessage(sender:Name(), ' был забанен ', PAW_MODULE('lib').Config.Colors.Red, 'навсегда', color_white, '.')
            sender:Ban(0, true)
        end
    end

    print('ПИДОР ОБНАРУЖЕН ->', sender)
end

net.Receive('Paws.Lib.Notify', Handler)