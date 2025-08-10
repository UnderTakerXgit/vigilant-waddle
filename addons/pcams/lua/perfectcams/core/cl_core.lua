--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

function PerfectCams.Render.DrawScreen(ent, w, h)
	local getApp = ent:GetApp()
	if not getApp then return end

	if not getApp.garbage.hasLoaded then
		getApp.Device = ent
		getApp:Load(ent, w, h)
		getApp.garbage.hasLoaded = true
	end

	// Render background
	draw.RoundedBox(0, 0, 0, w, h, PerfectCams.Colors.Black)
	
	// Render sidebar
	if (!getApp.HideSidebar) then	
		PerfectCams.Render.Sidebar(ent, 0, 0, 80, h)
	end

	// Render app
	getApp:Render(80, 0, w - (!getApp.HideSidebar and 80 or 0), h)
end


local home
function PerfectCams.Render.Sidebar(ent, x, y, w, h)
	draw.RoundedBox(0, x, y, w, h, PerfectCams.Colors.Gray)

	surface.SetDrawColor(255, 255, 255)

	surface.SetMaterial(PerfectCams.Core.GetImage("battery_50"))
	surface.DrawTexturedRectRotated(x + (w*0.3), y + 20, w*0.3, w*0.3, 0)

	surface.SetMaterial(PerfectCams.Core.GetImage("wifi_1"))
	surface.DrawTexturedRectRotated(x + (w*0.7), y + 20, w*0.3, w*0.3, 0)

	draw.SimpleText(os.date("%H:%M"), "pCams.Screen.Sidebar.Time", x + (w*0.5), y + (w*0.3) + 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


	if (!home) then
		local buttonSize = (w*0.8)
		home = PerfectCams.UI.New3DButton()
		home:SetPos(x + ((w*0.5) - (buttonSize * 0.5)), (y + h) - buttonSize - 10)
			:SetSize(buttonSize, buttonSize)

		home.paint = function(self, x, y, w, h)
			surface.SetDrawColor(self.hover and PerfectCams.Colors.WhiteLight or color_white)
	
			surface.SetMaterial(PerfectCams.Core.GetImage("home"))
			surface.DrawTexturedRect(x, y, w, h)
		end
	end

	home:DoClick(function()
			if (!ent) then return end
			ent:ChangeApp("hub")
		end)
		:Paint(home.paint)
end
 
PerfectCams.Images = {}
function PerfectCams.Core.MountImage(id, url, params)
	PerfectCams.Images[id] = {url = url, mat = Material(url, params or 'smooth nocull noclamp')}
end
function PerfectCams.Core.GetImage(id)
	return PerfectCams.Images[id].mat
end

PerfectCams.Core.MountImage("phone_logo", "materials/pcams/panopticon_logo.png")
PerfectCams.Core.MountImage("store_logo", "materials/pcams/panopticon_logo_2.png")
PerfectCams.Core.MountImage("arrow_left", "materials/pcams/arrow_left.png")
PerfectCams.Core.MountImage("arrow_right", "materials/pcams/arrow_right.png")
PerfectCams.Core.MountImage("arrow_up", "materials/pcams/arrow_up.png")
PerfectCams.Core.MountImage("arrow_down", "materials/pcams/arrow_down.png")
PerfectCams.Core.MountImage("arrow_up_right", "materials/pcams/arrow_up_right.png")
PerfectCams.Core.MountImage("arrow_rotate_up", "materials/pcams/arrow_rotate_up.png")
PerfectCams.Core.MountImage("arrow_rotate_down", "materials/pcams/arrow_rotate_down.png")
PerfectCams.Core.MountImage("arrow_rotate_left", "materials/pcams/arrow_rotate_left.png")
PerfectCams.Core.MountImage("arrow_rotate_right", "materials/pcams/arrow_rotate_right.png")
PerfectCams.Core.MountImage("battery_50", "materials/pcams/battery_50.png")
PerfectCams.Core.MountImage("eye", "materials/pcams/eye.png")
PerfectCams.Core.MountImage("home", "materials/pcams/home.png")
PerfectCams.Core.MountImage("link", "materials/pcams/link.png")
PerfectCams.Core.MountImage("social", "materials/pcams/social.png")
PerfectCams.Core.MountImage("wifi_1", "materials/pcams/wifi_1.png")
PerfectCams.Core.MountImage("wifi_2", "materials/pcams/wifi_2.png")
PerfectCams.Core.MountImage("wifi_3", "materials/pcams/wifi_3.png")
PerfectCams.Core.MountImage("wifi_4", "materials/pcams/wifi_4.png")
PerfectCams.Core.MountImage("wifi_5", "materials/pcams/wifi_5.png")
PerfectCams.Core.MountImage("dot", "materials/pcams/dot.png")
PerfectCams.Core.MountImage("square_rounded", "materials/pcams/square_rounded.png")
PerfectCams.Core.MountImage("static", "materials/pcams/static.png")


PerfectCams.Colors = {
	Black = Color(21, 21, 21),
	Gray = Color(36, 36, 36),
	GrayLight = Color(49, 49, 49),
	Red = Color(197, 49, 47),
	Green = Color(37, 154, 103),
	WhiteLight = Color(200, 200, 200)
}

hook.Add("PreRender", "pCams:UpdateActiveRT", function()
	hook.Add("HUDShouldDraw", "pCams:BlockDrawHUD", function(name) return false end)
	hook.Add("ShouldDrawLocalPlayer", "pCams:ShowUserInRT", function(ply) return true end)

	for k, v in pairs(PerfectCams.Cameras) do
		if not v.render then continue end

		local ent = ents.GetByIndex(v.entIndex)

		if not IsValid(ent) then continue end

		ent:UpdateRT()

		v.render = false
	end

	local pos = LocalPlayer():GetPos()
	for k, v in pairs(PerfectCams.Cache.TVs) do
		if (not IsValid(v:GetCamera())) then continue end
		if (v:GetPos():DistToSqr(pos) > 100000) then continue end

		v:GetCamera():UpdateRT()
	end

	hook.Remove("HUDShouldDraw", "pCams:BlockDrawHUD")
	hook.Remove("ShouldDrawLocalPlayer", "pCams:ShowUserInRT")
end)

-- Font was loading funny and this seems to fix it
hook.Add("PostDrawHUD", "pCams:LoadFonts", function()
	PerfectCams.UI.GenerateFonts()
	hook.Remove("PostDrawHUD", "pCams:LoadFonts")
end)
hook.Add("OnScreenSizeChanged", "pCams:ResChange", function()
	PerfectCams.UI.GenerateFonts()
end)

net.Receive("pCams:Camera:Created", function()
	local entIndex = net.ReadUInt(16)
	local name = net.ReadString()

	PerfectCams.Cameras[entIndex] = {
		entIndex = entIndex, // Entity might not e networked yet, so we just store the index
		name = name,
		render = false
	}
end)

net.Receive("pCams:Camera:Removed", function()
	local entIndex = net.ReadUInt(16)

	PerfectCams.Cameras[entIndex] = nil
end)

net.Receive("pCams:Store:UI", function()
	local npc = net.ReadEntity()

	PerfectCams.UI.StoreMenu(npc)
end)


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
