ENT.Base = 'base_anim'
ENT.Type = 'anim'

ENT.PrintName = 'Станция починки ВАР'
ENT.Author = 'Stan'
ENT.Category = '!Rephyx.tech | Утилиты'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = true

ENT.RepairAmount = 50
ENT.Radius = 500
ENT.RearmPrimarySegment = true
ENT.RearmSecondarySegment = true
ENT.RearmPrimaryAmount = 10
ENT.RearmSecondaryAmount = 10

function ENT:SetupDataTables()

	self:NetworkVar( 'Float', 0, 'Radius', { KeyName = 'radius', Edit = { title = 'Радиус', type = 'Float', order = 1,min = 0, max = 5000, category = 'Область'} } )
	self:NetworkVar( 'Float', 1, 'RepairAmount', { KeyName = 'repairamount', Edit = { title = 'ХП/1сек', type = 'Float', order = 2,min = 0, max = 10000, category = 'Починка'} } )
	
	self:NetworkVar( 'Int', 0, 'RearmPrimary', { KeyName = 'rearmprimary', Edit = { title = 'Перязарядка основного/1сек', type = 'Int', order = 3, min = 0, max = 10000, category = 'Перезарядка'} } )
	self:NetworkVar( 'Int', 1, 'RearmSecondary', { KeyName = 'rearmsecondary', Edit = { title = 'Перезарядка дополнительного/1сек', type = 'Int', order = 5, min = 0, max = 10000, category = 'Перезарядка'} } )
	
	self:NetworkVar( 'Bool', 0, 'RearmPrimarySegment', { KeyName = 'rearmprimarysegment', Edit = { title = 'Вкл/Выкл перезарядку основного', type = 'Boolean', order = 2, category = 'Перезарядка'} } )
	self:NetworkVar( 'Bool', 1, 'RearmSecondarySegment', { KeyName = 'rearmsecondarysegment', Edit = { title = 'Вкл/Выкл перезарядку дополнительного', type = 'Boolean', order = 4, category = 'Перезарядка'} } )
	
	self:NetworkVar( 'String', 0, 'VehName' )
	self:NetworkVar( 'String', 1, 'CurHP' )
	self:NetworkVar( 'String', 2, 'MaxHP' )

	if SERVER then
		self:SetRepairAmount( self.RepairAmount )
		self:SetRadius( self.Radius )
		self:SetRearmPrimarySegment( self.RearmPrimarySegment )
		self:SetRearmPrimary( self.RearmPrimaryAmount )
		self:SetRearmSecondarySegment( self.RearmSecondarySegment )
		self:SetRearmSecondary( self.RearmSecondaryAmount )

		self:SetVehName('Ожидание...')
		self:SetCurHP('0')
		self:SetMaxHP('0')

	end

end

if CLIENT then
	local function InverseLerp( pos, p1, p2 )
		local range = 0
		range = p2-p1
		if range == 0 then return 1 end
		return ((pos - p1)/range)
	end
	function ENT:Draw()
		self:DrawModel()

		local alpha = 255
		local viewdist = 250

		-- calculate alpha
		local max = viewdist
		local min = viewdist*0.75

		local dist = LocalPlayer():EyePos():Distance( self:GetPos() )

		if dist > min and dist < max then
			local frac = InverseLerp( dist, max, min )
			alpha = alpha * frac
		elseif dist > max then
			alpha = 0
		end

		local oang = self:GetAngles()
		local opos = self:GetPos()

		local ang = self:GetAngles()
		local pos = self:GetPos()

		ang:RotateAroundAxis( oang:Up(), 90 )
		ang:RotateAroundAxis( oang:Right(), -90 )
		ang:RotateAroundAxis( oang:Up(), -90)

		pos = pos + oang:Forward() * 0 + oang:Up() * 65  + oang:Right() * 17.5

		if alpha > 0 then
			cam.Start3D2D( pos, ang, 0.025 )
				draw.SimpleText( 'Станция починки', 'font_sans_3d2d_large', 0, 0, Color(52, 147, 235, alpha), TEXT_ALIGN_CENTER )
				draw.SimpleText( 'Чинит и перезаряжает технику', 'font_sans_3d2d_small', 0, 128, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )			
				draw.SimpleText( 'Просто подгоните технику к этой станции', 'font_sans_3d2d_small', 0, 128 + 72, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )		
				draw.SimpleText( self:GetVehName(), 'font_sans_3d2d_large', 0, 128 + 72 + 72, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )		
				draw.SimpleText( self:GetCurHP() .. ' / ' .. self:GetMaxHP(), 'font_sans_3d2d_small', 0, 128 + 72 + 72 + 128, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )		
			cam.End3D2D()
		end
	end
end