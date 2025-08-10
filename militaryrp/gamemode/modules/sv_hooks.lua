local spawnPos = {
	Vector(-7036.549316, 12184.619141, 128.031250),
	Vector(-7047.007813, 11890.061523, 140.261017),
	Vector(-7273.785645, 11952.074219, 129.262573),
	Vector(-7373.752930, 12184.865234, 128.031250),
}

function GM:PlayerSpawn( pPlayer )
    hook.Call( 'PlayerLoadout', GAMEMODE, pPlayer );

    player_manager.SetPlayerClass(pPlayer, team.playerClass or 'player_nextrp')

    hook.Run('PostPlayerSpawn', player)
    pPlayer.Initialized = true;

    local oldHands = pPlayer:GetHands()

    if (IsValid(oldHands)) then
        oldHands:Remove()
    end

    local handsEntity = ents.Create('gmod_hands')

    if (IsValid(handsEntity)) then
        pPlayer:SetHands(handsEntity)
        handsEntity:SetOwner(pPlayer)

        local info = player_manager.RunClass(pPlayer, 'GetHandsModel')

        if (info) then
            handsEntity:SetModel(info.model)
            handsEntity:SetSkin(info.skin)
            handsEntity:SetBodyGroups(info.body)
        end

        local viewModel = pPlayer:GetViewModel(0)
        handsEntity:AttachToViewmodel(viewModel)

        viewModel:DeleteOnRemove(handsEntity)
        pPlayer:DeleteOnRemove(handsEntity)

        handsEntity:Spawn()
    end
end

function GM:PlayerLoadout( pPlayer )
    pPlayer:ShouldDropWeapon(false)

    local job = NextRP.GetJob(pPlayer:Team())
    if not job then return end

    if (pPlayer:FlashlightIsOn()) then
        pPlayer:Flashlight(false)
    end;

    pPlayer:AllowFlashlight( true )

    pPlayer:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    pPlayer:SetMaterial('')
    pPlayer:SetMoveType(MOVETYPE_WALK)
    pPlayer:Extinguish()
    pPlayer:UnSpectate()
    pPlayer:GodDisable()
    pPlayer:ConCommand('-duck')
    pPlayer:SetColor(Color(255, 255, 255, 255))
    pPlayer:SetupHands()

    pPlayer:SetWalkSpeed(100)
    pPlayer:SetSlowWalkSpeed(200)
    pPlayer:SetRunSpeed(300)

    pPlayer:SetModelScale(1)

    pPlayer:SetPlayerColor( Vector( 1, 1, 1 ) )
    pPlayer:StripWeapons()

    local rank = pPlayer:GetNVar('nrp_rank')

    local hp = job.ranks[rank].hp or 100
    local armor = job.ranks[rank].ar or 0

    local char = pPlayer:CharacterByID(pPlayer:GetNVar('nrp_charid'))

    pPlayer:SetSkin(0)
    for k, v in pairs(pPlayer:GetBodyGroups()) do
        pPlayer:SetBodygroup(k, 0)
    end

    if istable(char.model) and char.model.model then
        pPlayer:SetModel(char.model.model)
    else
        local model = (istable(job.ranks[rank].model) and table.Random(job.ranks[rank].model) or job.ranks[rank].model) or 'models/Humans/Group01/male_09.mdl'
        pPlayer:SetModel(model)
    end

    if istable(char.model) and char.model.skin then
        pPlayer:SetSkin(tonumber(char.model.skin))
    end

    if istable(char.model) and char.model.bodygroups then
        for k, v in pairs(char.model.bodygroups) do
            pPlayer:SetBodygroup(tonumber(k), tonumber(v))
        end
    end

    pPlayer:SetMaxHealth(hp)
    pPlayer:SetHealth(hp)

    pPlayer:SetArmor(armor)

    local flags = pPlayer:GetNVar('nrp_charflags')
    local weps = false
    local hpf = false

    local weaponList = table.Copy(job.ranks[rank].weapon or {})
    pPlayer.ammunitionweps = {}

    for k, v in pairs(flags) do
        local flag = job.flags[k]
        if flag.replaceWeapon and weps == false then
            weps = flag.weapon
        elseif weps == false then
            table.Add(weaponList.default, flag.weapon.default)
            table.Add(weaponList.ammunition, flag.weapon.ammunition)
        end

        if flag.replaceHPandAR and hpf == false then
            hpf = {flag.hp, flag.ar}
        end
    end
    if weps ~= false then
        pPlayer.ammunitionweps = weps
        for k, v in pairs(weps.default) do
            pPlayer:Give(v)
        end
    else
        pPlayer.ammunitionweps = weaponList

        for k, v in pairs(weaponList.default) do
            pPlayer:Give(v)
        end
    end

    if hpf ~= false then
        pPlayer:SetMaxHealth(hpf[1])
        pPlayer:SetHealth(hpf[1])

        pPlayer:SetArmor(hpf[2])
    end

    pPlayer:Give('aspiration_hands')
    pPlayer:SelectWeapon('aspiration_hands')

    if pPlayer:getJobTable() then
        if pPlayer:getJobTable().type == TYPE_TERROR then
            pPlayer:SetPos(spawnPos[math.random(1, #spawnPos)])    
        end
    end

    return true;
end

function GM:LoadModules()
    local addon = GM.FolderName
    local recs = {}

    local _, luadirs = file.Find( addon .. "/lua/*", "GAME" )

    if #luadirs < 1 then
        recs[1] = addon .. "/lua"
    else
        for i=1,#luadirs do
            recs[i] = addon .. "/lua/" ..  luadirs[i]
        end
    end

    -- Make sure it opens the DIRECTORY. Else it would create a stack overflow.
    local opendir = addon .. "/lua/*"

    local files, dirs = file.Find( opendir, "GAME" )

    for i=1,#dirs do
        local dir = dirs[i]

        files = expandDir( files, addon .. "/lua/" .. dir .. "/*", 1 )
    end

    -- Nests ;-;
    for i=1,#files do
        for j=1,#recs do
            -- +6 because you add two forward slashes on the way, then "lua/". 
            -- Total of 6 chars.
            local rec = recs[j]

            local lua = string.sub( rec, string.len( addon )+6, string.len( rec ) )
            openScript( lua .. "/" ..  files[i] )
        end
    end

    table.Empty( recs )
end

function GM:ShowSpare1(pPlayer)
	pPlayer:ConCommand('simple_thirdperson_enable_toggle')
end
function GM:ShowSpare2(pPlayer)
	pPlayer:RequestCharacters(function(characters)
		pPlayer.Characters = characters or {}
		netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {col = color_white, text = ''})
	end)
end
function GM:ShowHelp(pPlayer)
	pPlayer:RequestCharacters(function(characters)
		pPlayer.Characters = characters or {}
		netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {col = color_white, text = ''})
	end)
end
function GM:ShowTeam(pPlayer)
	netstream.Start(pPlayer, 'NextRP::OpenRadio')
end

function GM:AllowPlayerPickup()
	return false
end

function GM:GetFallDamage( ply, flFallSpeed )
	return flFallSpeed * 0.1
end

function GM:PlayerSpawnSWEP(ply, class, info)
	return ply:IsAdmin()
end

function GM:PlayerGiveSWEP(ply, class, info)
	return ply:IsAdmin()
end

function GM:PlayerSpawnEffect(ply, model)
	return ply:IsAdmin()
end

function GM:PlayerSpawnVehicle(ply, model, class, info)
	return ply:IsAdmin()
end

function GM:PlayerSpawnedVehicle(ply, ent)
	return ply:IsAdmin()
end

function GM:PlayerSpawnNPC(ply, type, weapon)
	return ply:IsAdmin()
end

function GM:PlayerSpawnedNPC(ply, ent)
	return ply:IsAdmin()
end

function GM:PlayerSpawnRagdoll(ply, model)
	return ply:IsAdmin()
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	return ply:IsAdmin()
end

function GM:PlayerSpawnSENT(ply, class)
    return ply:IsAdmin()
end

function GM:PlayerSpawnProp(ply, model)
    return ply:IsAdmin()
end

function GM:PlayerEnteredVehicle( pPlayer, vehicle, role )
    return false
end

function GM:PlayerUse(pl, ent)
	return true
end

function GM:OnPhysgunFreeze(weapon, phys, ent, pl)
	if ent.PhysgunFreeze and (ent:PhysgunFreeze(pl) == false) then
		return false
	end

	if ( ent:GetPersistent() ) then return false end

	-- Object is already frozen (!?)
	if ( !phys:IsMoveable() ) then return false end
	if ( ent:GetUnFreezable() ) then return false end

	phys:EnableMotion( false )

	-- With the jeep we need to pause all of its physics objects
	-- to stop it spazzing out and killing the server.
	if ( ent:GetClass() == 'prop_vehicle_jeep' ) then

		local objects = ent:GetPhysicsObjectCount()

		for i = 0, objects - 1 do

			local physobject = ent:GetPhysicsObjectNum( i )
			physobject:EnableMotion( false )

		end

	end

	-- Add it to the player's frozen props
	pl:AddFrozenPhysicsObject( ent, phys )

	return true
end

hook.Add( 'CanProperty', '!!!!!!!!!!!!!!!!!!!a', function( ply, property, ent )

	if not ply:IsAdmin() then
		ply:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете использовать это!')
		return false
	end
	
	return ply:IsAdmin()
end )