AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel('models/hunter/plates/plate2x4.mdl')
	self:SetSolid( SOLID_BBOX )
	self:DropToFloor()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	self:SetMaterial( 'models/debug/debugwhite' )
	self:SetColor(Color(68, 189, 50))
	self:DrawShadow(false)
end

function ENT:Use()
	self:DropToFloor()
end
