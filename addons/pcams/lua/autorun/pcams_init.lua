--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

PerfectCams = {}
PerfectCams.Config = {}
PerfectCams.Translation = {}
PerfectCams.Core = {}
PerfectCams.Apps = {}
PerfectCams.UI = {}
PerfectCams.Render = {}
PerfectCams.Cooldown = {}
PerfectCams.Libs = {}
PerfectCams.Cameras = {}
PerfectCams.Share = {}
PerfectCams.Database = {}
PerfectCams.Cache = {
	TVs = {}
}
PerfectCams.Canvas = {
	w = 1362,
	h = 886
}
PerfectCams.ENUM = {
	LEFT = 1,
	RIGHT = 2,
	UP = 3,
	DOWN = 4,
	PRIMARY = 5
}

print("Loading PerfectCams")

local path = "perfectcams/"
if SERVER then
	resource.AddWorkshop("3402226113")

	local files, folders = file.Find(path .. "*", "LUA")
	
	for _, folder in SortedPairs(folders, true) do
		print("Loading folder:", folder)
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        AddCSLuaFile(path .. folder .. "/" .. File)
	        include(path .. folder .. "/" .. File)
	    end
	
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sv_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        include(path .. folder .. "/" .. File)
	    end
	
	    for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        AddCSLuaFile(path .. folder .. "/" .. File)
	    end
	end

	resource.AddSingleFile("resource/fonts/inter.ttf")
end

if CLIENT then
	local files, folders = file.Find(path .. "*", "LUA")
	
	for _, folder in SortedPairs(folders, true) do
		print("Loading folder:", folder)
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        include(path .. folder .. "/" .. File)
	    end

	    for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        include(path .. folder .. "/" .. File)
	    end
	end

	PerfectCams.Libs.Imgui = include("perfectcams/libs/cl_imgui.lua")
end

-- We also need to load the apps
PerfectCams.Apps.Find()

concommand.Add("pcams_force_reload", function(ply)
    if not IsValid(ply) then return end

    if not PerfectCams or not PerfectCams.API or not PerfectCams.API.SendPlayerCameras then
        ply:ChatPrint("[pCams] ❌ PerfectCams.API.SendPlayerCameras не загружен.")
        return
    end

    PerfectCams.API.SendPlayerCameras(ply)
    ply:ChatPrint("[pCams] ✅ Камеры повторно отправлены.")
end)

print("Loaded PerfectCams")

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
