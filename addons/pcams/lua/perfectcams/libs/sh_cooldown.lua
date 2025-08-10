--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

-- A cooldown lib I stole from my community's lib
PerfectCams.Cooldown.Timers = PerfectCams.Cooldown.Timers or {}

function PerfectCams.Cooldown.Check(id, time, ply)
	if not id then return true end
	if not time then return true end

	if not PerfectCams.Cooldown.Timers[id] then
		PerfectCams.Cooldown.Timers[id] = {}
		PerfectCams.Cooldown.Timers[id].global = 0
	end

	if ply then
		if not PerfectCams.Cooldown.Timers[id][ply:SteamID64()] then
			PerfectCams.Cooldown.Timers[id][ply:SteamID64()] = 0
		end

		if PerfectCams.Cooldown.Timers[id][ply:SteamID64()] > CurTime() then return true end

		PerfectCams.Cooldown.Timers[id][ply:SteamID64()] = CurTime() + time

		return false
	else
		if PerfectCams.Cooldown.Timers[id].global > CurTime() then return true end

		PerfectCams.Cooldown.Timers[id].global = CurTime() + time

		return false
	end
end

function PerfectCams.Cooldown.Get(id, ply)
	if not id then return 0 end

	if not PerfectCams.Cooldown.Timers[id] then return 0 end

	-- The correct returns
	if ply and PerfectCams.Cooldown.Timers[id][ply:SteamID64()] then return PerfectCams.Cooldown.Timers[id][ply:SteamID64()] end
	if not ply and PerfectCams.Cooldown.Timers[id].global then return PerfectCams.Cooldown.Timers[id].global end

	-- Failsafe
	return 0
end


function PerfectCams.Cooldown.Reset(id, ply)
	if not id then return end

	if not PerfectCams.Cooldown.Timers[id] then return end

	if ply then
		if not PerfectCams.Cooldown.Timers[id][ply:SteamID64()] then return end
		PerfectCams.Cooldown.Timers[id][ply:SteamID64()] = 0
	else
		PerfectCams.Cooldown.Timers[id].global = 0
	end
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
