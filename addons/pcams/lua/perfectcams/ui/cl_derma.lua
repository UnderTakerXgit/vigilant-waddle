--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

function PerfectCams.UI.StoreMenu(npc)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.3, ScrH() * 0.8)
    frame:Center()
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:DockPadding(20, 70, 20, 20)
    function frame:Paint(w, h)
        draw.RoundedBox(20, 0, 0, w, h, PerfectCams.Colors.Black)

        -- Render logo
        local logoMat = PerfectCams.Core.GetImage("store_logo")
        
        surface.SetDrawColor(color_white)
        surface.SetMaterial(logoMat)
        surface.DrawTexturedRect(20, 20, 98, 30)
    end

    local close = vgui.Create("DButton", frame)
    close:SetSize(30, 30)
    close:SetPos(frame:GetWide() - 50, 20)
    close:SetText('')
    function close:Paint(w, h)
        draw.SimpleText('X', "pCams.NPC.SubTitle", w, h*0.5, self:IsHovered() and PerfectCams.Colors.Red or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    function close:DoClick()
        frame:Remove()
    end


    local shell = vgui.Create("DScrollPanel", frame)
    shell:Dock(FILL)
	shell.Paint = function() end

	local sbar = shell:GetVBar()
	sbar:SetHideButtons(true)

	function sbar:Paint(w, h)
        local halfW = w*0.5
		draw.RoundedBox(10, halfW, 0, halfW, h, PerfectCams.Colors.Gray)
	end
	function sbar.btnGrip:Paint(w, h)
        local halfW = w*0.5
		draw.RoundedBox(10, halfW, 0, halfW, h, PerfectCams.Colors.GrayLight)
	end


    local ply = LocalPlayer()
    for k, v in ipairs(PerfectCams.Config.Store.Items) do
        local entity = scripted_ents.Get(v.class) or weapons.Get(v.class)
        local worldModel = entity.WorldModel or entity.Model

        local item = vgui.Create("DPanel")
        shell:AddItem(item)
        item:Dock(TOP)
        item:SetTall(100)
        item:DockMargin(0, 0, 0, 20)
        function item:Paint(w, h)
            draw.RoundedBox(10, 0, 0, w, h, PerfectCams.Colors.Gray)
        end

        local model = vgui.Create("DModelPanel", item)
        model:Dock(LEFT)
        model:SetWide(item:GetTall())
        model:SetModel(worldModel)
        -- *|* Credit: https://wiki.garrysmod.com/page/DModelPanel/SetCamPos
        local mn, mx = model.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        model:SetFOV(30)
        model:SetCamPos(Vector(size+4, size+4, size+4))
        model:SetLookAt((mn + mx)*0.5)
    
        local text = vgui.Create("DPanel", item)
        text:Dock(FILL)
        function text:Paint(w, h)
            draw.SimpleText(v.name, "pCams.NPC.Title", 10, 22, PerfectCams.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(PerfectCams.Config.Store.Format(v.price), "pCams.NPC.SubTitle", 10, h-22, PerfectCams.Config.Store.CanAfford(LocalPlayer(), v.price) and PerfectCams.Colors.Green or PerfectCams.Colors.Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
    
        local buy = vgui.Create("Button", item)
        buy:SetWide(90)
        buy:Dock(RIGHT)
        buy:DockMargin(10, 30, 10, 30)
        buy:SetText('')

        function buy:Paint(w, h)
            draw.RoundedBox(10, 0, 0, w, h, ((!v.canPurchase or v.canPurchase(ply)) and PerfectCams.Config.Store.CanAfford(ply, v.price)) and PerfectCams.Colors.Green or PerfectCams.Colors.Red)
            draw.SimpleText(PerfectCams.Translation.NPC.Buy, "pCams.NPC.SubTitle", w*0.5, h*0.5, PerfectCams.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function buy:DoClick()
            net.Start("pCams:Store:Buy")
                net.WriteEntity(npc)
                net.WriteUInt(k, 5)
            net.SendToServer()

            frame:Close()
        end
            
    end
end

local colorTrans = Color(0, 0, 0, 200)
function PerfectCams.Core.PromptInput(title, subtitle, callback)
	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW(), ScrH())
	frame:SetPos(0, 0)
	frame:SetTitle('')
	//frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:MakePopup()
	function frame:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colorTrans)
	end

	local height = ScreenScaleH(14) + ScreenScaleH(8) + 20 + 80

	local shell = vgui.Create("DPanel", frame)
	shell:SetSize(ScrW() * 0.3, height)
	shell:Center()
	shell:DockPadding(10, 50, 10, 10)
	function shell:Paint(w, h)
		draw.RoundedBox(20, 0, 0, w, h, PerfectCams.Colors.Gray)	
		draw.SimpleText(title, "pCams.Prompt.Title", w*0.5, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(subtitle, "pCams.Prompt.SubTitle", w*0.5, 40, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local textInput

	local submit = vgui.Create("DButton", shell)
	submit:SetTall(30)
	submit:Dock(BOTTOM)
	submit:SetText('')
	submit:DockMargin(0, 10, 0, 0)
	function submit:DoClick()
		callback(textInput:GetValue())
		frame:Remove()
	end
	function submit:Paint(w, h)
		draw.RoundedBox(10, 0, 0, w, h, PerfectCams.Colors.Green)
	
		draw.SimpleText('Submit', "pCams.Prompt.SubTitle", w*0.5, h*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	textInput = vgui.Create("DTextEntry", shell)
	textInput:SetTall(30)
	textInput:Dock(BOTTOM)
	textInput:SetFont("pCams.Prompt.Input")
	function textInput:Paint(w, h)
		draw.RoundedBox(10, 0, 0, w, h, PerfectCams.Colors.GrayLight)

		self:DrawTextEntryText(color_white, PerfectCams.Colors.Black, color_white)
	end
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
