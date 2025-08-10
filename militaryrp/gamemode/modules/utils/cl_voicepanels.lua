local PANEL = {}
NextRPPlayerVoicePanels = NextRPPlayerVoicePanels or {}

local PlayerVoicePanels = NextRPPlayerVoicePanels

function PANEL:Init()
    self.Avatar = vgui.Create('AvatarImage', self)
    self.Avatar:Dock(LEFT)
    self.Avatar:SetSize(32, 32)

    self.Radio = vgui.Create('DPanel', self)
    self.Radio:SetPos(250 - 36, 4)
    self.Radio:SetSize(32, 32)

    self:SetSize(250, 32 + 8)
    self:DockPadding(4, 4, 4, 4)
    self:DockMargin(2, 2, 2, 2)
    self:Dock(BOTTOM)
    self.Nick = ''
    self.Past = {}
end

function PANEL:Setup(ply)
    self.ply = ply
    self.Avatar:SetPlayer(ply)
    self:InvalidateLayout()

    PAW_MODULE('lib'):Download('nwrp/radio_vp.png', 'https://i.ibb.co/hs6Q4MQ/walkie-talkie.png', function(dPath)
        local mat = Material(dPath, 'smooth')

        function self.Radio:Paint()
            if ply:GetNVar('radio_mic') then
                surface.SetDrawColor(255, 255, 255, 200)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, 32, 32)
            end
        end
    end)

    PlayerVoicePanels[self.ply] = self
end

function PANEL:Paint(w, h)
	if IsValid(self) and IsValid(self.ply) then

    	table.insert(self.Past, self.ply:VoiceVolume())
    	
        local len = #self.Past
    	if len > (42 - 1) then table.remove(self.Past, 1) end
    	draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
    	
        for i, v in pairs(self.Past) do
        	local barh = v * 40
        	surface.SetDrawColor(self:GetBarColor(v * 100))
        	surface.DrawRect(35 + i * 5, 36 - barh, 5, barh)
    	end

    	surface.SetFont('font_sans_21')

    	local _, h = surface.GetTextSize( tostring(self.ply:GetRank()) .. ' ' .. tostring(self.ply:Name()) )

    	surface.SetTextColor(Color(255, 255, 255))
    	surface.SetTextPos(40, 40 * 0.5 - h * 0.8)
    	surface.DrawText( tostring(self.ply:GetRank()) .. ' ' .. tostring(self.ply:Name()) )

        local spec = self.ply:GetNVar('nrp_charflags')
        local jt = self.ply:getJobTable()

        local final = 'Без специализации'
        for k, v in pairs(spec) do
            if not istable(final) then final = {} end
            final[#final + 1] = jt.flags[k].id
        end

        if istable(final) then
            final = table.concat(final, ', ')
        end

        surface.SetFont('font_sans_16')
        surface.SetTextPos(40, 40 * 0.5)
    	surface.DrawText(final)

	end
end

function PANEL:GetBarColor(p)
    if p >= 70 then
        return Color(255, 0, 0, 50)
    elseif p >= 45 then
        return Color(255, 255, 0, 50)
    elseif p >= 10 then
        return Color(0, 255, 0, 50)
    else
        return Color(0, 255, 0, 50)
    end
end

function PANEL:Think()
    if self:IsValid() and self.fadeAnim then self.fadeAnim:Run() end
end

function PANEL:FadeOut(anim, delta, data)
	self:SetAlpha(255 - (255 * delta*50))
	if anim.Finished then
        if IsValid(PlayerVoicePanels[self.ply]) then
            PlayerVoicePanels[self.ply]:Remove()
            PlayerVoicePanels[self.ply] = nil
            return
        end
        return
    end
end

derma.DefineControl('VoiceNotify', '', PANEL, 'DPanel')