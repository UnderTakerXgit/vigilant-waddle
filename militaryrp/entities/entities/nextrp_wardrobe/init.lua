AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( 'models/props_blackmesa/supercomputer01a.mdl' )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() 
	end

	self:SetUseType(SIMPLE_USE)
end
 
function ENT:Use( activator, caller )
	if caller:IsPlayer() then
		local modelInfo = caller:CharacterByID(caller:GetNVar('nrp_charid')).model
		netstream.Start(caller, 'NextRP::OpenWardrobe', modelInfo)
	end
end