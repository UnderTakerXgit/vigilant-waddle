GM.Name = 'MilitaryRP'
GM.Version = 'rHRP#1.0.1'

-- Информация про автора, не юзайте слитый, напишите мне.
GM.Author = 'TheLovelyMask'
GM.Email = 'poxui'
GM.Website = 'poxui'

-- Подтягиваем функции с сандбокса
DeriveGamemode('sandbox')

MsgC('\n==============================================\n=\n')
MsgC('= NodeFrame | Biohazard начал загружаться.\n= Версия: '..GM.Version..'\n= Разработчик: TheLovelyMask & VolVer\n=\n')
MsgC('==============================================\n\n')

hook.Run('NextRP::StartLoading')

include('libs/pon.lua')
AddCSLuaFile('libs/pon.lua')
MsgC('PON загружен.\n')

include('libs/nw.lua')
AddCSLuaFile('libs/nw.lua')
MsgC('NW загружен.\n')
--
AddCSLuaFile('gamemodes/militaryrp/weapons/stungun.lua')
--
include('libs/netstream.lua')
AddCSLuaFile('libs/netstream.lua')
MsgC('NetStream v2 загружен.\n')

include('libs/mysqlite.lua')
AddCSLuaFile('libs/mysqlite.lua')
MsgC('MySQLite загружен.\n')

include('libs/paws/loader.lua')
AddCSLuaFile('libs/paws/loader.lua')
MsgC('Aww... Paws! Lib загружена.\n')

include('libs/pawsui/loader.lua')
AddCSLuaFile('libs/pawsui/loader.lua')
MsgC('Paws UI загружена.\n')

if CLIENT then 
    include('libs/paws/paws_lib/vgui/cl_tdlib.lua')
    include('libs/paws/paws_lib/vgui/cl_fonts.lua')
end
AddCSLuaFile('libs/paws/paws_lib/vgui/cl_tdlib.lua')
AddCSLuaFile('libs/paws/paws_lib/vgui/cl_fonts.lua')

MsgC('FORCED: TDLib!\n') 
MsgC('FORCED: FONTS!\n') 

-- Глобальная таблица
NextRP = {
    Config = {},
    -- Main systems
    Jobs = {},
    JobsByID = {},
    Whitelist = {},
    -- Components
    Utils = {},
    Database = {},
    -- Sub-system
    Chars = {},
    Ranks = {},
    Scoreboard = {},
    NPC = {},
    -- Cars
    Cars = {}
}

-- Загружаем конфиги
function NextRP.LoadConfigs(self)
    local sPath = GM.FolderName..'/gamemode/config/'

    local files, folders = file.Find(sPath..'/*.lua', 'LUA')

    for k, v in pairs(files) do
        if string.StartWith(v, 'sv') then
            if SERVER then
                local load = include(sPath..v)
                if load then load() end
            end 
        end

        if string.StartWith(v, 'cl') then
            if CLIENT then
                local load = include(sPath..v)
                if load then load() end 
            end

            AddCSLuaFile(sPath..v)
        end

        if string.StartWith(v, 'sh') then
            local load = include(sPath..v)
            if load then load() end

            AddCSLuaFile(sPath..v)
        end 

        MsgC(Color(190, 252, 3), '[ Rephyx.tech ]', '[ Конфиг ]', ' Файл "'..v..'" загружен успешно!\n')
    end
end
-- Загружаем модули
function NextRP.LoadModules(self)
    local sPath = GM.FolderName..'/gamemode/modules/'

    local files, folders = file.Find(sPath..'/*', 'LUA')
    local loaded = false

    for k, v in pairs(files) do
        if string.StartWith(v, 'sv') then
            if SERVER then
                local load = include(sPath..v)
                if load then load() end
            end 

            loaded = true
        end

        if string.StartWith(v, 'cl') then
            if CLIENT then
                local load = include(sPath..v)
                if load then load() end 
            end

            AddCSLuaFile(sPath..v)
            loaded = true
        end

        if string.StartWith(v, 'sh') then
            local load = include(sPath..v)
            if load then load() end

            AddCSLuaFile(sPath..v)
            loaded = true
        end 

        if loaded then MsgC(Color(190, 252, 3), '[ NodeFrame | Biohazard ]', '[ Модули ]', ' Файл "'..v..'" загружен успешно!\n', sPath..v, '\n') end
    end

    for k, v in pairs(folders) do
        local files = file.Find(sPath..v..'/*.lua', 'LUA')

        for kf, vf in pairs(files) do
            if string.StartWith(vf, 'sv') then
                if SERVER then
                    local load = include(sPath..v..'/'..vf)
                    if load then load() end
                    
                end 
            end

            if string.StartWith(vf, 'cl') then
                if CLIENT then
                    local load = include(sPath..v..'/'..vf)
                    
                    if load then load() end 
                end

                AddCSLuaFile(sPath..v..'/'..vf)
            end

            if string.StartWith(vf, 'sh') then
                local load = include(sPath..v..'/'..vf)
                if load then load() end

                AddCSLuaFile(sPath..v..'/'..vf)
            end 

            MsgC(Color(190, 252, 3), '[ NodeFrame | Biohazard ]', '[ Модули | ', v, ' ]', ' Файл "'..vf..'" загружен успешно!\n', sPath..v..'/'..vf, '\n')
        end
    end
end

hook.Run('NextRP::PreModulesLoad')
NextRP:LoadModules()
hook.Run('NextRP::ModulesLoaded')

hook.Run('NextRP::PreConfigLoad')
NextRP:LoadConfigs()
hook.Run('NextRP::ConfigLoaded')

hook.Run('NextRP::EndLoading')

MsgC('\n==============================================\n=\n')
MsgC('= NodeFrame | Biohazard завершил загружаться.\n= Версия: 1.0.1d\n= Разработчик: TheLovelyMask\n=\n')
MsgC('==============================================\n')