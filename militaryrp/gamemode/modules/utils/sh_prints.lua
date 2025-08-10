if SERVER then
    
    function NextRP.Utils.Print(bOnlyServer, pPlayer, ...)
        local args = {...}
        MsgC(Color(66, 135, 245), '[ NF | Biohazard: Umbrella Containment Zone ] ', color_white, unpack(args), '\n')
        if !bOnlyServer then
            if IsValid(pPlayer) then
                netstream.start(pPlayer, 'NextRP::Print', ... )
            else
                netstream.start(nil, 'NextRP::Print', ... )
            end
        end
    end

elseif CLIENT then
    
    netstream.Hook('NextRP::Print', function(...)
        MsgC(Color(66, 135, 245), '[ NF | Biohazard: Umbrella Containment Zone ] ', color_white, unpack(args), '\n')
    end)

end