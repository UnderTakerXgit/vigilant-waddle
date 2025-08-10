include('shared.lua')

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
	ang:RotateAroundAxis( oang:Right(), -70 )
	--ang:RotateAroundAxis( oang:Up(), 90)

	pos = pos + oang:Forward() * 16 + oang:Up() * 17  + oang:Right() * 0

	if alpha > 0 then
		cam.Start3D2D( pos, ang, 0.025 )
			draw.SimpleText( 'Шкаф', 'font_sans_3d2d_large', 0, 0, Color(52, 147, 235, alpha), TEXT_ALIGN_CENTER )
			draw.SimpleText( 'Изменить внешний вид персонажа возможно тут.', 'font_sans_3d2d_small', 0, 128, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )			
			draw.SimpleText( 'Нажмите [Е] что бы воспользоваться.', 'font_sans_3d2d_small', 0, 128 + 72, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )			
		cam.End3D2D()
	end
end

