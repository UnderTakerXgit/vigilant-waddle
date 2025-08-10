local W = ScrW
local H = ScrH
local helpText = [[Выбирайте модель, скины, элементы формы в правом меню.
Тяните по горизонтали что-бы крутить модель.
Тяните по вертикали что отдалить/приплизить модель.
Тяните с зажатой правой кнопкой мыши что-бы изменять позицию камеры.]]

local function InverseLerp( pos, p1, p2 )

	local range = 0
	range = p2-p1

	if range == 0 then return 1 end

	return ((pos - p1)/range)

end

local ui = {}

function ui:openwardrobe(modelInfo)
    
    local job = LocalPlayer():getJobTable()
    local rank = LocalPlayer():GetRank()

    self.modelInfo = modelInfo

    local frame = TDLib('DPanel')
        :ClearPaint()
        :Background(Color(53, 57, 68, 200), 3)

    frame:SetSize(W() - 30, H() - 60)
    frame:MakePopup()
    frame:Center()

    self.frame = frame
    local icon = TDLib( 'DModelPanel', frame )
        :Stick(FILL)
        :On('Paint', function()
            draw.DrawText(helpText, 'font_sans_21', 5, 5)
        end)
    
    self.modelPanel = icon

    if modelInfo then 
        if modelInfo.model then
            icon:SetModel(modelInfo.model)
        else
            local model = istable(job.ranks[rank].model) and table.Random(job.ranks[rank].model) or job.ranks[rank].model
            icon:SetModel(model)
        end

        if modelInfo.skin then
            icon.Entity:SetSkin(tonumber(modelInfo.skin))
        end

        if modelInfo.bodygroups then
            for k, v in pairs(modelInfo.bodygroups) do
                icon.Entity:SetBodygroup(tonumber(k), tonumber(v))
            end
        end
    else
        local model = istable(job.ranks[rank].model) and table.Random(job.ranks[rank].model) or job.ranks[rank].model
        icon:SetModel(model)
    end
    
    icon:SetLookAt( Vector(0,0,72/2) )
	icon:SetCamPos( Vector(64,0,72/2))
	--icon:SetLookAng( Angle(0,0,0) )

	icon.Entity:SetEyeTarget( icon.Entity:GetPos() + Vector(200,0,64) )

	-- icon:SetAmbientLight( Color(10,15,50) )
	-- icon:SetDirectionalLight( BOX_TOP, Color(220,190,100) )

	icon.rot = 110
	icon.fov = 20
	icon:SetFOV( icon.fov )
	icon.dragging = false -- left click
	icon.dragging2 = false -- right click
	icon.ux = 0
	icon.uy = 0
	icon.spinmul = 0.4
	icon.zoommul = 0.09

	icon.xmod = 0
	icon.ymod = 0
    
    function icon:LayoutEntity( ent )

		local newrot = self.rot
		local newfov = self:GetFOV()

		if self.dragging == true then
			newrot = self.rot + (gui.MouseX() - self.ux)*self.spinmul
			newfov = self.fov + (self.uy - gui.MouseY()) * self.zoommul
			if newfov < 20 then newfov = 20 end
			if newfov > 75 then newfov = 75 end
		end

		local newxmod, newymod = self.xmod, self.ymod

		if self.dragging2 == true then
			newxmod = self.xmod + (self.ux - gui.MouseX())*0.02
			newymod = self.ymod + (self.uy - gui.MouseY())*0.02
		end

		newxmod = math.Clamp( newxmod, -16, 16 )
		newymod = math.Clamp( newymod, -16, 16 )

		ent:SetAngles( Angle(0,0,0) )
		self:SetFOV( newfov )

		-- calculate if we should look at the face
		local height = 72/2
		-- fov between 20 and 75,
		-- height between 72/2 and 72
		local frac = InverseLerp( newfov, 75, 20 )
		height = Lerp( frac, 72/2, 64 )

		-- calculate look ang
		local norm = (self:GetCamPos() - Vector(0,0,64))
		norm:Normalize()
		local lookAng = norm:Angle()

		self:SetLookAt( Vector(0,0,height-(2*frac) ) - Vector( 0, 0, newymod*2*(1-frac) ) - lookAng:Right()*newxmod*2*(1-frac) )
		self:SetCamPos( Vector( 64*math.sin( newrot * (math.pi/180)), 64*math.cos( newrot * (math.pi/180)), height + 4*(1-frac)) - Vector( 0, 0, newymod*2*(1-frac) ) - lookAng:Right()*newxmod*2*(1-frac) )

	end
	function icon:OnMousePressed( k )
		self.ux = gui.MouseX()
		self.uy = gui.MouseY()
		self.dragging = (k == MOUSE_LEFT) or false 
		self.dragging2 = (k == MOUSE_RIGHT) or false 
	end
	function icon:OnMouseReleased( k )
		if self.dragging == true then
			self.rot = self.rot + (gui.MouseX() - self.ux)*self.spinmul
			self.fov = self.fov + (self.uy - gui.MouseY()) * self.zoommul
			self.fov = math.Clamp( self.fov, 20, 75 )
		end

		if self.dragging2 == true then
			self.xmod = self.xmod + (self.ux - gui.MouseX())*0.02
			self.ymod = self.ymod + (self.uy - gui.MouseY())*0.02

			self.xmod = math.Clamp( self.xmod, -16, 16 )
			self.ymod = math.Clamp( self.ymod, -16, 16 )
		end

		self.dragging = false 
		self.dragging2 = false
	end
	function icon:OnCursorExited()
		if self.dragging == true or self.dragging2 == true then
			self:OnMouseReleased()
		end
	end

    self.LEFTSide = TDLib('DPanel', frame)
        :Stick(RIGHT)
        :DivWide(3)
        :ClearPaint()
        :Background(Color(53, 57, 68), 3)

    self.scrollpanel = TDLib('DScrollPanel', self.LEFTSide)
        :Stick(FILL)
        --:ClearPaint()
        --:Background(Color(225, 57, 68), 3)

    self.buttons = TDLib('DIconLayout', self.scrollpanel)
        --:Stick(FILL, 8)
        --:Background(Color(225, 57, 68), 3)
    
    self.buttons:SetSize( self.scrollpanel:GetWide()-8, self.scrollpanel:GetTall() - 8 )
	self.buttons:SetPos( 4, 4 )

    -- self.scrollpanel:Add(self.buttons)

    self.buttons:SetSpaceX( 4 )
    self.buttons:SetSpaceY( 4 )

    local close = TDLib('DButton', self.LEFTSide)
        :ClearPaint()
        :Text('Закрыть', 'font_sans_21', nil)
        :Stick(BOTTOM, 5)
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
        :CircleClick(nil, 5, 35)
        :SetRemove(self.frame)
    
    close:SetTall(35)

    local confirm = TDLib('DButton', self.LEFTSide)
        :ClearPaint()
        :Text('Сохранить', 'font_sans_26', nil)
        :Stick(BOTTOM, 5)
        :Background(Color(53 - 15, 57 - 15, 68 - 15))
        :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
        :CircleClick(nil, 5, 35)
        :On('DoClick', function()
            netstream.Start('NextRP::SaveCharAppereance', self.Info)
        end)
    
    confirm:SetTall(45)

    self:update()
end

function ui:update()
    if not self.modelInfo then
        self.Info = {
            model = LocalPlayer():GetModel(),
            skin = LocalPlayer():GetSkin(),
            bodygroups = {}
        }
    else
        self.Info = {
            model = self.modelPanel:GetModel(),
            skin = self.modelInfo.skin,
            bodygroups = self.modelInfo.bodygroups
        }
    end

    local job = LocalPlayer():getJobTable()
    local rank = LocalPlayer():GetRank()

    local buttons = self.buttons
    local playerModels = table.Copy(job.ranks[rank].model)

    buttons:Clear()

    local title = buttons:Add('DLabel')
    title:TDLib()
        :ClearPaint()
        :Text('Внешний вид персонажа', 'font_sans_35', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    title:SizeToContentsY()

    local flags = LocalPlayer():GetNVar('nrp_charflags')
    for k, v in pairs(flags) do
		local flag = job.flags[k]
        if flag.replaceModel then
            playerModels = flag.model
            break 
        else
            table.Add(playerModels, flag.model)
        end
    end

    if istable(playerModels) then
        local modelPlaceHolder = buttons:Add('DLabel')
        modelPlaceHolder:TDLib()
            :ClearPaint()
            :Text('Модель', 'font_sans_26', nil, TEXT_ALIGN_LEFT)
            :DivWide(1)

        for k = 1, #playerModels do
            local model = playerModels[k]
            local args = string.Split( model, "/" )
			local mdlname = args[ #args ]
			mdlname = string.sub( mdlname, 1, -5)
            
            local btn = buttons:Add( 'DButton' )
            btn:TDLib()
                :ClearPaint()
                :Background(Color(53 - 15, 57 - 15, 68 - 15))
                :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
                :CircleClick(nil, 5, 35)
                :Text(mdlname, 'font_sans_21')
                :On('DoClick', function()
                    self.Info.model = model
                    self.modelPanel:SetModel(model)
                    self:update()
                end)
        
            btn:SetWide( (buttons:GetWide()-8) * .5 - 8 )
            btn:SetTall( 28 )
            
        end
    end

    local skintable = {}
    for i=0, self.modelPanel.Entity:SkinCount() - 1 do
        table.insert( skintable, i )
    end

	if skintable != {} then
		local skinPlaceHolder = buttons:Add('DLabel')
        skinPlaceHolder:TDLib()
            :ClearPaint()
            :Text('Скины', 'font_sans_26', nil, TEXT_ALIGN_LEFT)
            :DivWide(1)
		

		for k, i in ipairs(skintable) do
            local btn = buttons:Add( 'DButton' )
            btn:TDLib()
                :ClearPaint()
                :Background(Color(53 - 15, 57 - 15, 68 - 15))
                :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
                :CircleClick(nil, 5, 35)
                :Text(k, 'font_sans_21')
                :On('DoClick', function()
                    self.modelPanel.Entity:SetSkin(i)
                    self.Info.skin = i
                end)
        
            btn:SetWide( buttons:GetWide() * .25 - 16 )
            btn:SetTall( 28 )
		end

		local spacer = buttons:Add('DPanel')
		spacer:SetSize(buttons:GetWide(), 2)
		function spacer:Paint() end
	end

    local bodygroups = {}
    for k, v in pairs(self.modelPanel.Entity:GetBodyGroups()) do
        if v.num <= 1 then continue end
        bodygroups[#bodygroups + 1] = v
    end

    if bodygroups != {} then
        local bgPlaceHolder = buttons:Add('DLabel')
        bgPlaceHolder:TDLib()
            :ClearPaint()
            :Text('Элементы формы', 'font_sans_26', nil, TEXT_ALIGN_LEFT)
            :DivWide(1)

        for k, v in pairs(bodygroups) do
            local title = buttons:Add('DPanel')
            title:TDLib()
                :ClearPaint()
                :Text(v.name, 'font_sans_21', nil, TEXT_ALIGN_LEFT)
                :DivWide(1)
            for id, _ in pairs(v.submodels) do
                local btn = buttons:Add( 'DButton' )
                btn:TDLib()
                    :ClearPaint()
                    :Background(Color(53 - 15, 57 - 15, 68 - 15))
                    :FadeHover(Color(53 - 10, 57 - 10, 68 - 10))
                    :CircleClick(nil, 5, 35)
                    :Text(id, 'font_sans_21')
                    :On('DoClick', function()
                        self.modelPanel.Entity:SetBodygroup(v.id, id)
                        self.Info.bodygroups = self.Info.bodygroups or {}
                        self.Info.bodygroups[v.id] = id
                    end)
            
                btn:SetWide( buttons:GetWide() * .25 - 16 )
                btn:SetTall( 28 )
            end
        end
    end
end

netstream.Hook('NextRP::OpenWardrobe', function(modelInfo) ui:openwardrobe(modelInfo) end)