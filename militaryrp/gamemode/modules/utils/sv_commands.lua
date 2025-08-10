local function WrongArgs(MODULE, pPlayer)
    MODULE:SendNotify(pPlayer, 'Неверные аргументы!', nil, 4, MODULE.Config.Colors.Red)
end

local function LoadCommands(MODULE)

    local MESSAGES_TYPE = MODULE.Config.Chat.MESSAGES_TYPE

    // chat commands

    MODULE:Command('y').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 550, Color(255, 69, 56), '[Крик] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.Chat', 'y', pPlayer, sText)
    end

    MODULE:Command('w').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[Шёпот] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.Chat', 'w', pPlayer, sText)
    end

    // rp commands

    MODULE:Command('me').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[ME] ', Color(252, 186, 255), pPlayer:FullName(), ' ', sText ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'me', pPlayer, sText)
    end

    MODULE:Command('do').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[DO] ', Color(252, 186, 255), sText, ' ( ', pPlayer:FullName(), ' )' ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'do', pPlayer, sText)
    end

    MODULE:Command('try').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        local Chance = math.random(0, 100) >= 50
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[TRY] ', Color(252, 186, 255), pPlayer:FullName(), ' ', Chance and Color(83, 199, 0) or Color(255, 69, 56), Chance and 'успешно' or 'безуспешно', Color(252, 186, 255), ' выполнил действие: ', sText ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'try', pPlayer, sText, Chance)
    end

    // animation commands

    MODULE:Command('salute').Run = function( pPlayer, sText )
        pPlayer:Say('/me исполнил воинское приветствие')
        pPlayer:DoAnimationEvent( ACT_GMOD_TAUNT_SALUTE ) 
    end
	
	MODULE:Command('idn').Run = function( pPlayer, sText )
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[ME] ', Color(252, 186, 255), ' Показал свои документы: ', team.GetColor(pPlayer:Team()), '                                                         Полное имя: ', pPlayer:Name(), Color(252, 186, 255), ' / ', team.GetColor(pPlayer:Team()), 'Звание: ', pPlayer:GetRank(), Color(252, 186, 255), '' , team.GetColor(pPlayer:Team())  ) 
        hook.Run('Paws.Lib.CommandRun.RP', 'idn', pPlayer, sText)
	end

    MODULE:Command('bow').Run = function( pPlayer, sText )
        pPlayer:Say('/me поклонился')
        pPlayer:DoAnimationEvent( ACT_GMOD_GESTURE_BOW ) 
    end

    MODULE:Command('forward').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Вперёд"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_FORWARD ) 
    end

    MODULE:Command('group').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Сгруппироваться"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_GROUP ) 
    end

    MODULE:Command('halt').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Стоп"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_HALT ) 
    end

    MODULE:Command('point').Run = function( pPlayer, sText )
        pPlayer:Say('/me указал')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_FORWARD )
        pPlayer:ConCommand('mcompass_spot')
    end


    // ooc commands

    local function rp(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[Global ME] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.OOC', 'rp', pPlayer, sText)
    end

    MODULE:Command('rp').Run = rp


    local function ooc(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[OOC] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.OOC', 'ooc', pPlayer, sText)
    end

    MODULE:Command('ooc').Run = ooc
    MODULE:Command('/').Run = ooc
    MODULE:Command('a').Run = ooc

    local function looc(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 250, Color(255, 129, 56), '[LOOC]', color_white, ' (( ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText, ' ))' ) 

        hook.Run('Paws.Lib.CommandRun.LOOC', 'looc', pPlayer, sText)
    end

    MODULE:Command('looc').Run = looc
    MODULE:Command('l').Run = looc
    MODULE:Command('lo').Run = looc

    // servermsg

    local function servermsg(pPlayer, sText)
        if !pPlayer:IsAdmin() then return end
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[СЕРВЕР] ', Color(255,0,0), sText ) 
    end

    MODULE:Command('sm').Run = servermsg
    MODULE:Command('servermessage').Run = servermsg
    MODULE:Command('servermsg').Run = servermsg

    local function getmodel(pPlayer, sText)
        local ent = pPlayer:GetEyeTrace().Entity

        if IsValid(ent) then
            MODULE:SendMessage(pPlayer, -1, 'Модель получена: ', ent:GetModel(), ' и скопирована в буфер обмена.')
            pPlayer:SendLua('SetClipboardText("'..ent:GetModel()..'")')
        end
    end

    MODULE:Command('getmodel').Run = getmodel

    local function base(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        for k, v in pairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[БАЗА] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', Color(252, 219, 3), sText ) 
        end
    end

    MODULE:Command('base').Run = base
	
	    local function adverti(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        for k, v in pairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[Рация] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', Color(252, 219, 3), sText ) 
        end
    end

    MODULE:Command('ad').Run = adverti
	
end

hook.Add('Paws.lib.Loaded', 'LoadCommands', LoadCommands)

if PAW_MODULE('lib').Loaded then
    LoadCommands(PAW_MODULE('lib'))
end 