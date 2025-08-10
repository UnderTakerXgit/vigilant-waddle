local function Handler(_, sender)
    -- local ply = net.ReadEntity()
    -- local MSG_TYPE = net.ReadInt(8)
    -- local data = net.ReadTable()

    -- net.Start('Paws.Lib.Msg')
    --     net.WriteInt(MSG_TYPE, 8)
    --     net.WriteTable(data)
    -- net.Send(ply)

    for k,v in ipairs(player.GetHumans()) do
        if v:IsAdmin() then
            PAW_MODULE('lib'):SendMessage(v, 0, Color(255,0,0), sender:Name(), ' попытался проникнуть в луа, но удача мамкиного хакера отвернулась от него.')

            PAW_MODULE('lib'):SendConsoleMessage(sender:Name(), ' был забанен ', PAW_MODULE('lib').Config.Colors.Red, 'навсегда', color_white, '.')
            sender:Ban(0, true)
        end
    end

end

net.Receive('Paws.Lib.Msg', Handler)