--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


-- Circle Function
-- Created by Ben.
local sinCache = {}
local cosCache = {}
for i = 0, 360 do
	sinCache[i] = math.sin(math.rad(i))
	cosCache[i] = math.cos(math.rad(i))
end
function PerfectCams.UI.DrawCircle(x, y, r, step)
    local positions = {}

    for i = 0, 360, step do
        table.insert(positions, {
            x = x + cosCache[i] * r,
            y = y + sinCache[i] * r
        })
    end

    return surface.DrawPoly(positions)
end




--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
