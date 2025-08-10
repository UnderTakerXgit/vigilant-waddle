function GM:PlayerInitialSpawn(pPlayer) -- это сука ебаный костыль, ебал я ваш проект сука
    hook.Add( 'SetupMove', pPlayer, function( self, ply, _, cmd )
        if self == ply and not cmd:IsForced() then
            hook.Run( 'NextRP::PlayerFullLoad', self )
            hook.Remove( 'SetupMove', self )
        end
    end )
end

hook.Add('NextRP::PlayerFullLoad', 'LoadIDPLS', function(pPlayer)
    local sSteamID = pPlayer:SteamID()
    MySQLite.query(
        string.format(
            'SELECT * FROM `nextrp_players` WHERE steam_id = %s;',
            MySQLite.SQLStr(sSteamID)
        ),
    
        function(tPlayerData)
            if tPlayerData and istable(tPlayerData) then
                pPlayer:SetNVar('nrp_id', tPlayerData[1].id, NETWORK_PROTOCOL_PUBLIC)
                pPlayer:SetNVar('nrp_slots', tPlayerData[1].char_slots, NETWORK_PROTOCOL_PUBLIC)

                pPlayer.Characters = {}
                hook.Run('NextRP::PlayerIDRetrived', pPlayer, tPlayerData[1].id)
            else
                MySQLite.query(string.format('INSERT INTO `nextrp_players`(steam_id, community_id, discord_id, char_slots) VALUES(%s, %s, %s, %s);',
                    MySQLite.SQLStr( pPlayer:SteamID() ),
                    MySQLite.SQLStr( pPlayer:SteamID64() ),
                    false,
                    1
                ), function(_, id)
                    pPlayer:SetNVar('nrp_id', id, NETWORK_PROTOCOL_PUBLIC)
                    pPlayer:SetNVar('nrp_slots', 1, NETWORK_PROTOCOL_PUBLIC)

                    pPlayer.Characters = {}

                    hook.Run('NextRP::PlayerIDRetrived', pPlayer, id)
                end)
            end
        end
    )
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if not IsValid(listener) or not IsValid(talker) then return end
    
    if not listener:Alive() then return false, false end
    if not talker:Alive() then return false, false end

    return listener:GetPos():Distance(talker:GetPos()) <= 400, true
end

function GM:PlayerCanSeePlayersChat( text, bTeam, listener, talker )
    if not IsValid(listener) or not IsValid(talker) then return end
    
    if not listener:Alive() then return false end
    if not talker:Alive() then return false end

    return listener:GetPos():Distance( talker:GetPos() ) <= 300
end