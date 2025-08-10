hook.Add( 'DatabaseInitialized', 'DatabaseInitialized2', function() 
    
    MySQLite.query([[
		CREATE TABLE IF NOT EXISTS nextrp_players(
            id int auto_increment not null primary key,
			steam_id varchar(25),
			community_id TEXT,
            discord_id varchar(255),
            char_slots INT
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
	]],function(result)
        print('Пытаемся создать БД для игроков!')
    end,function(err)
		print(err)
	end)
	MySQLite.query([[
		CREATE TABLE IF NOT EXISTS nextrp_characters(
            character_id int auto_increment not null primary key,
			player_id INT,
            rpid varchar(255),
            `rank` varchar(255),
            `flag` TEXT,
            character_name varchar(255),
            character_surname varchar(255),
            character_nickname varchar(255),
            team_id varchar(255),
            model varchar(255),
            money int,
            level INT,
            exp INT,
            inventory TEXT
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
	]],function()
        print('Пытаемся создать БД для персонажей!')
    end,
    function(err)
		print(err)
	end)
end)

local pMeta = FindMetaTable('Player')

function pMeta:SavePlayerData( name, value )
    local str = isnumber(value) and '%d' or '%s'
    value = isnumber(value) and value or MySQLite.SQLStr(value)

    MySQLite.query( string.format( 'UPDATE nextrp_players SET %s = '..str..' WHERE steam_id = %s;',
        name,
        value,
        MySQLite.SQLStr( self:SteamID() )
    ))
end