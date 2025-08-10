--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

-- This just creates the font. To keep them organised
function PerfectCams.UI.GenerateFonts()
	surface.CreateFont("pCams.App.Title", {
		font = "Inter ExtraBold",
		size = 25,
	})
	surface.CreateFont("pCams.App.view3r.Nav", {
		font = "Inter",
		size = 30,
	})
	surface.CreateFont("pCams.App.view3r.Title", {
		font = "Inter SemiBold",
		size = 35,
	})
	surface.CreateFont("pCams.App.view3r.SubTitle", {
		font = "Inter Medium",
		size = 25,
	})
	surface.CreateFont("pCams.App.Icon", {
		font = "Inter",
		size = 150,
	})
	surface.CreateFont("pCams.Phone.Header", {
		font = "Inter ExtraBold",
		size = 23,
	})
	surface.CreateFont("pCams.Screen.Text", {
		font = "Inter Medium",
		size = 30,
	})
	
	
	surface.CreateFont("pCams.Screen.Sidebar.Time", {
		font = "Inter ExtraBold",
		size = 24,
	})
	surface.CreateFont("pCams.Screen.Title", {
		font = "Inter ExtraBold",
		size = 46,
	})
	surface.CreateFont("pCams.Screen.SubTitle", {
		font = "Inter Medium",
		size = 32,
	})
	surface.CreateFont("pCams.Screen.Text", {
		font = "Inter SemiBold",
		size = 35,
	})
	
	surface.CreateFont("pCams.NPC.Overhead", {
		font = "Inter Medium",
		size = 90,
	})
	surface.CreateFont("pCams.NPC.Title", {
		font = "Inter Bold",
		size = 32,
	})
	surface.CreateFont("pCams.NPC.SubTitle", {
		font = "Inter Medium",
		size = 24,
	})
	
	surface.CreateFont("pCams.Prompt.Title", {
		font = "Inter ExtraBold",
		size = ScreenScaleH(14),
	})
	surface.CreateFont("pCams.Prompt.SubTitle", {
		font = "Inter Medium",
		size = ScreenScaleH(8),
	})
	surface.CreateFont("pCams.Prompt.Input", {
		font = "Inter",
		size = 14,
	})
	
	surface.CreateFont("pCams.Deploy.HUD", {
		font = "Inter Bold",
		size = ScreenScaleH(20),
	})
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
