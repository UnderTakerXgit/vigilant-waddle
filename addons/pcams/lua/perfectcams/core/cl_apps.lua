--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

PerfectCams.Apps.All = PerfectCams.Apps.All or {}

function PerfectCams.Apps.Register(name, data)
	print("Registering", name)
	PerfectCams.Apps.All[name] = data
end

function PerfectCams.Apps.Get(name)
	return PerfectCams.Apps.All[name]
end 

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
