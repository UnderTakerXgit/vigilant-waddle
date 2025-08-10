local fn = GM.FolderName

local function IncludeClient(path)
	if CLIENT then
		include(fn..'/gamemode/libs/pawsui/' .. path)
	end

	if SERVER then
		AddCSLuaFile(fn..'/gamemode/libs/pawsui/' .. path)
	end
end 

local function IncludeServer(path) 
	if SERVER then
		include(fn..'/gamemode/libs/pawsui/' .. path)
	end
end 

local function IncludeShared(path)
	IncludeServer(path)
	IncludeClient(path) 
end
 
local function load()
    IncludeClient('settings.lua')
	for k, v in pairs(file.Find(fn..'/gamemode/libs/pawsui/elements/*.lua', 'LUA')) do 
		IncludeClient('elements/'..v)
	end

	for k, v in pairs(file.Find(fn..'/gamemode/libs/pawsui/libs/*.lua', 'LUA')) do 
		IncludeClient('libs/'..v)
	end
end 

if GAMEMODE then
	load()
else
	hook.Add('InitPostEntity', 'KTS.Load.RanksSystem', function()
        load()
	end)
end
 