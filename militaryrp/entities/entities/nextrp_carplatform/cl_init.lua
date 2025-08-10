include('shared.lua')

local SHOULD_DRAW = CreateConVar( 'nrp_showplatforms', 0, FCVAR_ARCHIVE, 'Показывает или скрывает сообщения' )

function ENT:Initialize()
	self:SetNoDraw(true)
end

function ENT:Think()
	local shouldDraw = SHOULD_DRAW:GetBool()

	self:SetNoDraw(!shouldDraw)
end

function ENT:Draw()
	if( self:GetNoDraw() ) then return end
    self:DrawModel()

    local distance = LocalPlayer():GetPos():DistToSqr(self:GetPos())
	if(distance > 30000 * 2) then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + ang:Up() + Vector(0, 0, 5)

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local alpha = math.Clamp(math.Remap(distance, 30000 * 0.25, 30000, 255, 0), 0, 255)

    cam.Start3D2D( pos, ang, 0.025 )
		draw.SimpleText( 'Спавн платформа #' .. self:GetNumber(), 'font_sans_3d2d_large', 0, 0, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER )
	cam.End3D2D()
end 

