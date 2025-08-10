--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

-- We have to run this server side so we can load the files to send to the client.
function PerfectCams.Apps.Find()
	print("Loading apps:")
	for _, File in SortedPairs(file.Find("perfectcams/core/apps/*.lua", "LUA"), true) do
		if SERVER then
			AddCSLuaFile("perfectcams/core/apps/" .. File)
		else
			print("Loading App: ", File)
	   		local data = include("perfectcams/core/apps/" .. File)
		
			if (not data) or (not data.UniqueName) then continue end -- No unique name given 
			PerfectCams.Apps.Register(data.UniqueName, data)
		end	
	end
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
