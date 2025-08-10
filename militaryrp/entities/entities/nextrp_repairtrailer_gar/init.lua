AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel('models/valk/h3/unsc/props/server/server.mdl')
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:NextThink(CurTime())
end

function ENT:Think()
	self:SetVehName('Ожидание...')
	self:SetCurHP('0')
	self:SetMaxHP('0')
	for _, e in pairs(ents.FindInSphere(self:GetPos(), self:GetRadius())) do
		if IsValid( e ) then
			local IsVehicle = e:GetClass() == 'gmod_sent_vehicle_fphysics_base'
			local IsWheel = e:GetClass() == 'gmod_sent_vehicle_fphysics_wheel'
			if e.LFS then
				local RepairAmount = self:GetRepairAmount() 
				
				local lfsHP = e:GetHP()
				local lfsMHP = e:GetMaxHP()

				self:SetVehName('Починка...')
				self:SetCurHP(lfsHP)
				self:SetMaxHP(lfsMHP)

				if lfsHP < lfsMHP then
					e:SetHP( lfsHP + RepairAmount )
					e:EmitSound('lfs/repair_loop.wav', 100, 100)
				end
				
				local lfsAP = e:GetAmmoPrimary()
				local lfsMAP = e:GetMaxAmmoPrimary()
				local lfsAS = e:GetAmmoSecondary()
				local lfsMAS = e:GetMaxAmmoSecondary()
				if lfsAP < lfsMAP then
					local PrimaryBySegments = self:GetRearmPrimarySegment()
					local PrimaryRearmAmount = self:GetRearmPrimary()
					if PrimaryBySegments then
						e:SetAmmoPrimary( lfsAP + math.ceil( lfsMAP / PrimaryRearmAmount ) )
						e:EmitSound('items/ammo_pickup.wav', 100, 100)
					else
						e:SetAmmoPrimary( lfsAP + PrimaryRearmAmount )
						e:EmitSound('items/ammo_pickup.wav', 100, 100)
					end
				end
				if lfsAS < lfsMAS then
					local SecondaryBySegments = self:GetRearmSecondarySegment()
					local SecondaryRearmAmount = self:GetRearmSecondary()
					if SecondaryBySegments then
						e:SetAmmoSecondary( lfsAS + math.ceil( lfsMAS / SecondaryRearmAmount ) )
						e:EmitSound('items/ammo_pickup.wav', 100, 100)
					else
						e:SetAmmoSecondary( lfsAS + SecondaryRearmAmount )
						e:EmitSound('items/ammo_pickup.wav', 100, 100)
					end
				end
			elseif IsVehicle then			
				local MaxHealth = e:GetMaxHealth()
				local Health = e:GetCurHealth()

				self:SetVehName('Починка...')
				self:SetCurHP(Health)
				self:SetMaxHP(MaxHealth)
				
				if Health < MaxHealth then
					local NewHealth = math.min(Health + 50, MaxHealth)
					
					if NewHealth > (MaxHealth * 0.6) then
						e:SetOnFire( false )
						e:SetOnSmoke( false )
					end
				
					if NewHealth > (MaxHealth * 0.3) then
						e:SetOnFire( false )
						if NewHealth <= (MaxHealth * 0.6) then
							e:SetOnSmoke( true )
						end
					end
					
					e:SetCurHealth( NewHealth )
					e:EmitSound('lfs/repair_loop.wav', 100, 100)
				end
			elseif IsWheel then
				self:SetVehName('Починка...')
				if e:GetDamaged() then
					e:SetDamaged( false )
					e:EmitSound('lfs/repair_loop.wav', 100, 100)
				end
			end
		end
	end
	self:NextThink(CurTime()+1)
	return true
end