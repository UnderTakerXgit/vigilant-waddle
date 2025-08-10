local MODULE = PAW_MODULE('lib')

local function ParseCommand(pPlayer, sText)
    local tArgs
    local sCommand
    local sText2
    local tCommand
    local sPrefix = string.sub(sText, 0, 1)

    if sPrefix == '/' or sPrefix == '!' then
        sText = string.sub(sText, 2)

        tArgs = string.Split(sText, ' ')
        sCommand = tArgs[1]      
        sText2 = table.concat(tArgs, ' ', 2)

        tCommand = MODULE:Command(sCommand, true)

        if tCommand != nil then
            if pPlayer:GetNWBool('TMuted') == true then
                MODULE:SendMessage(pPlayer, -1, Color(255, 0, 0), 'Вы в муте и не можете использовать команды!')
                return ''
            end
            tCommand:OnRun(pPlayer, sText2, tArgs)

            return ''
        end        
    else        
        if tCommand == nil then
            if pPlayer:GetNWBool('TMuted') == true then
                MODULE:SendMessage(pPlayer, -1, Color(255, 0, 0), 'Вы в муте и не можете использовать чат!')
                return ''
            end

            hook.Run('Paws.Lib.CommandRun.All', 'chat', pPlayer, sText)
        end         
    end

    
end 

hook.Add('PlayerSay', 'Paws.Lib.Command.Hook', function( pPlayer, sText )
    return ParseCommand(pPlayer, sText)  
end)

 