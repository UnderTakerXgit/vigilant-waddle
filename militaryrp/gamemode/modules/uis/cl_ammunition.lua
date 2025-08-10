local function generateWeapons(scrollPanel, tWeapons)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
		:Stick(TOP, 2)
		:ClearPaint()
		:On('OnToggle', function(self) 
		
			if self:GetExpanded() then
				self.Header:TDLib()
					:ClearPaint()
					:Background(Color(53 + 10, 57 + 10, 68 + 10, 255))
			else
				self.Header:TDLib()
					:ClearPaint()
					:Background(Color(53 - 10, 57 - 10, 68 - 10, 255))
			end
	
		end)

	DCategory.Header:TDLib()
		:ClearPaint()
		:Text('Получаемое', 'font_sans_21')

	if DCategory:GetExpanded() then
		DCategory.Header:TDLib():Background(Color(53 + 10, 57 + 10, 68 + 10, 255))
	else
		DCategory.Header:TDLib():Background(Color(53 - 10, 57 - 10, 68 - 10, 255))
	end

	DCategory.Header:SetTall(25)

	local contents = vgui.Create('DPanelList', DCategory)

	contents:SetPadding(0)
	contents:SetSpacing(4)
	DCategory:SetContents(contents)

	for k, wep in pairs(tWeapons) do
		local tWep = weapons.Get(wep)
		if tWep == nil then continue end
		
		local pnl = TDLib('DPanel')
			:Stick(TOP, 1)
			:ClearPaint()
			:Background(Color(53 + 15, 57 + 15, 68 + 15, 255))

		local wepMat = Material('entities/'..wep..'.png', 'smooth')

		local icon = TDLib('DPanel', pnl)
			:Stick(LEFT, 2)
			:ClearPaint()
			--:Text('icon', 'font_sans_16')
			

		PAW_MODULE('lib'):Download('nw/noicon.png', 'https://i.imgur.com/yaqb1ND.png', function(dPath)
			local mat = Material(dPath, 'smooth')
			if wepMat:IsError() then
				icon:Material(mat)
			else
				icon:Material(wepMat)
			end
		end)

		icon:SetWide(64)

		local title = TDLib('DPanel', pnl)
			:Stick(TOP, 2)
			:ClearPaint()
			:Text(tWep.PrintName or wep, 'font_sans_21', nil, TEXT_ALIGN_LEFT)

		local reciveButton = TDLib('DButton', pnl)
			:ClearPaint()
			:Stick(FILL, 2)
			:Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
			:FadeHover(Color(255, 255, 255, 50))
			:LinedCorners()
			--:Text(LocalPlayer():HasWeapon(wep) and 'Сдать' or 'Получить', 'font_sans_21')
			:On('Think', function(s)
				s:Text(LocalPlayer():HasWeapon(wep) and 'Сдать' or 'Получить', 'font_sans_21')
			end)
			:On('DoClick', function()
				netstream.Start('NextRP::AmmunitionWeps', wep)
			end)

		pnl:SetTall(64 + 2)
		contents:Add(pnl)
	end
end
local function generateDWeapons(scrollPanel, tDWeapons)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
		:Stick(TOP, 2)
		:ClearPaint()
		:On('OnToggle', function(self) 
		
			if self:GetExpanded() then
				self.Header:TDLib()
					:ClearPaint()
					:Background(Color(53 + 10, 57 + 10, 68 + 10, 255))
			else
				self.Header:TDLib()
					:ClearPaint()
					:Background(Color(53 - 10, 57 - 10, 68 - 10, 255))
			end
	
		end)

	DCategory.Header:TDLib()
		:ClearPaint()
		:Text('Стандартное', 'font_sans_21')

	if DCategory:GetExpanded() then
		DCategory.Header:TDLib():Background(Color(53 + 10, 57 + 10, 68 + 10, 255))
	else
		DCategory.Header:TDLib():Background(Color(53 - 10, 57 - 10, 68 - 10, 255))
	end

	DCategory.Header:SetTall(25)

	local contents = vgui.Create('DPanelList', DCategory)

	contents:SetPadding(0)
	contents:SetSpacing(4)
	DCategory:SetContents(contents)

	for k, wep in pairs(tDWeapons) do
		local tWep = weapons.Get(wep)
		if tWep == nil then continue end
		
		local pnl = TDLib('DPanel')
			:Stick(TOP, 1)
			:ClearPaint()
			:Background(Color(53 + 15, 57 + 15, 68 + 15, 255))

		local wepMat = Material('entities/'..wep..'.png', 'smooth')

		local icon = TDLib('DPanel', pnl)
			:Stick(LEFT, 2)
			:ClearPaint()
			--:Text('icon', 'font_sans_16')
			

		PAW_MODULE('lib'):Download('nw/noicon.png', 'https://i.imgur.com/yaqb1ND.png', function(dPath)
			local mat = Material(dPath, 'smooth')
			if wepMat:IsError() then
				icon:Material(mat)
			else
				icon:Material(wepMat)
			end
		end)

		icon:SetWide(64)

		local title = TDLib('DPanel', pnl)
			:Stick(TOP, 2)
			:ClearPaint()
			:Text(tWep.PrintName or wep, 'font_sans_21', nil, TEXT_ALIGN_LEFT)

		local reciveButton = TDLib('DButton', pnl)
			:ClearPaint()
			:Stick(FILL, 2)
			:Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
			:FadeHover(Color(255, 255, 255, 50))
			:LinedCorners()
			--:Text(LocalPlayer():HasWeapon(wep) and 'Сдать' or 'Получить', 'font_sans_21')
			:On('Think', function(s)
				s:Text(LocalPlayer():HasWeapon(wep) and 'Сдать' or 'Получить', 'font_sans_21')
			end)
			:On('DoClick', function()
				netstream.Start('NextRP::AmmunitionWeps', wep)
			end)

		pnl:SetTall(64 + 2)
		contents:Add(pnl)
	end
end

local function Ammunition(tWeapons, tDWeapons)
    local frame = TDLib('DPanel')
		:ClearPaint()
		:Background(Color(53, 57, 68), 3)
		:FadeIn()
	
	frame:SetSize(500, 600)
	frame:Center()
	frame:MakePopup()

	frame.Blur = TDLib('DPanel')
		:ClearPaint()
		:Blur()
		:FadeIn()

	frame.Blur:SetSize(ScrW(), ScrH())

	function frame:OnRemove()
		self.Blur:Remove()
	end

	local header = TDLib('DPanel', frame)
		:ClearPaint()
		:DualText('Оружейный ящик', 'font_sans_26', color_white, 'Получить, либо сдать вооружение и экипировку можно тут.', 'font_sans_21', Color(170, 170, 170))
		:Stick(TOP)

	header:SetTall(45)

	header:DockMargin(0, 5, 0, 5)

	local scrollPanel = TDLib('DScrollPanel', frame)
        :Stick(FILL, 2)

	local scrollPanelBar = scrollPanel:GetVBar()
	scrollPanelBar:TDLib()
		:ClearPaint()
		:Background(Color(53, 57, 68, 50))

	scrollPanelBar.btnUp:TDLib()
		:ClearPaint()
		:Background(Color(53, 57, 68))
		:CircleClick()

	scrollPanelBar.btnDown:TDLib()
		:ClearPaint()
		:Background(Color(53, 57, 68))
		:CircleClick()

	scrollPanelBar.btnGrip:TDLib()
		:ClearPaint()
		:Background(Color(53, 57, 68))
		:CircleClick()

	if table.Count(tWeapons) > 0 then
        generateWeapons(scrollPanel, tWeapons)
    end
    if table.Count(tDWeapons) > 0 then
        generateDWeapons(scrollPanel, tDWeapons)
    end

	local CloseButton = TDLib('DButton', frame)
        :Stick(BOTTOM, 5)
        :ClearPaint() 
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover()
        :Text('Закрыть', 'font_sans_16')
        :CircleClick(nil, nil, 35)
        :SetRemove(frame)
end

netstream.Hook('NextRP::OpenAmmunitionMenu', function(tWeapons, tDWeapons)
	Ammunition(tWeapons, tDWeapons)
end)