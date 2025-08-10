if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName			= 'Руки'
SWEP.Author				= 'Pozitron'
SWEP.Purpose				= 'Не так уж и много.'
SWEP.Spawnable				= true
SWEP.Category				= 'Other'

SWEP.ViewModel			= 'models/weapons/c_medkit.mdl'
SWEP.WorldModel			= ''

SWEP.AnimPrefix	 		= 'rpg'

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= 'none'

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= 'none'

SWEP.DrawCrosshair = false

function SWEP:Initialize()
	self:SetHoldType( 'normal' )

	self.Time = 0
	self.Range = 100
end

function SWEP:Think()
	if self.Drag and (not self.Owner:KeyDown(IN_ATTACK) or not IsValid(self.Drag.Entity)) then
		if self.Drag.Entity.Carry then self.Drag.Entity:SetCarrier(nil) end
		self.Drag = nil
	end
end

function SWEP:PrimaryAttack()
	local Pos = self.Owner:GetShootPos()
	local Aim = self.Owner:GetAimVector()

	local Tr = util.TraceLine{
		start = Pos,
		endpos = Pos +Aim *self.Range,
		filter = player.GetAll(),
	}

	local HitEnt = Tr.Entity
	if self.Drag then
		HitEnt = self.Drag.Entity
	else
		if not IsValid( HitEnt ) or HitEnt:GetMoveType() ~= MOVETYPE_VPHYSICS or
			HitEnt:IsVehicle() or
			HitEnt.noDrag or
			IsValid( HitEnt:GetParent() ) or
			HitEnt.LFS then
			return
		end

		if not self.Drag then
			self.Drag = {
				OffPos = HitEnt:WorldToLocal(Tr.HitPos),
				Entity = HitEnt,
				Fraction = Tr.Fraction,
			}
		end
	end

	if self.Drag.Entity.Carry then self.Drag.Entity:SetCarrier(self.Owner) end

	if CLIENT or not IsValid( HitEnt ) then return end

	local Phys = HitEnt:GetPhysicsObject()

	if IsValid( Phys ) then
		if Phys:GetVolume() > math.pow(10, 5.85) then return end
		local Pos2 = Pos +Aim *self.Range *self.Drag.Fraction
		local OffPos = HitEnt:LocalToWorld( self.Drag.OffPos )
		local Dif = Pos2 -OffPos
		local Nom = (Dif:GetNormal() *math.min(1, Dif:Length() /100) *500 -Phys:GetVelocity()) *Phys:GetMass()

		Phys:ApplyForceOffset( Nom, OffPos )
		Phys:AddAngleVelocity( -Phys:GetAngleVelocity() /4 )
	end
end

function SWEP:SecondaryAttack()
end

if CLIENT then
	local x, y = ScrW(), ScrH()
	local MainCol = Color( 255, 255, 255, 255 )
	local Col = Color( 255, 255, 255, 255 )

	function SWEP:DrawHUD()
		if IsValid( self.Owner:GetVehicle() ) then return end
		local Pos = self.Owner:GetShootPos()
		local Aim = self.Owner:GetAimVector()

		local Tr = util.TraceLine{
			start = Pos,
			endpos = Pos +Aim *self.Range,
			filter = player.GetAll(),
		}

		local HitEnt = Tr.Entity
		

		if IsValid( HitEnt ) and HitEnt:GetMoveType() == MOVETYPE_VPHYSICS and
			not HitEnt.noDrag and
			not HitEnt:IsVehicle() and
			not IsValid( HitEnt:GetParent() ) and
			not HitEnt.LFS then

			self.Time = math.min( 1, self.Time +2 *FrameTime() )
		else
			self.Time = math.max( 0, self.Time -2 *FrameTime() )
		end

		if self.Time > 0 then
			Col.a = MainCol.a *self.Time

			surface.SetDrawColor(255, 255, 255, Col.a)
			surface.DrawRect( x * 0.5 - 2, y * 0.5 - 2, 4, 4, MainCol )
		end

		if self.Drag and IsValid( self.Drag.Entity ) then
			local Pos2 = Pos +Aim *100 *self.Drag.Fraction
			local OffPos = self.Drag.Entity:LocalToWorld( self.Drag.OffPos )
			local Dif = Pos2 -OffPos

			local A = OffPos:ToScreen()
			local B = Pos2:ToScreen()

			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawRect( A.x -2, A.y -2, 4, 4, MainCol )
			surface.DrawRect( B.x -2, B.y -2, 4, 4, MainCol )
			surface.DrawLine( A.x, A.y, B.x, B.y, MainCol )
		end
	end
end

function SWEP:PreDrawViewModel( vm, pl, wep )
	return true
end
