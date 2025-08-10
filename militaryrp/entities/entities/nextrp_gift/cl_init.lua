include('shared.lua')

function ENT:Draw()
    self:DrawModel()

	local distance = LocalPlayer():GetPos():DistToSqr(self:GetPos())
	if(distance > 30000) then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + ang:Up() + Vector(0, 0, 35)

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local alpha = math.Clamp(math.Remap(distance, 30000 * 0.25, 30000, 255, 0), 0, 255)

    cam.Start3D2D( pos, ang, 0.025 )
		draw.SimpleText( 'Подарок', 'font_sans_3d2d_large', 0, 0, Color(52, 147, 235, alpha), TEXT_ALIGN_CENTER )
		draw.SimpleText( 'С Новым 2021 годом!', 'font_sans_3d2d_small', 0, 128, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )			
		draw.SimpleText( 'Нажмите [ E ] что-бы открыть!', 'font_sans_3d2d_small', 0, 128 + 72, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

