--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

function PerfectCams.Core.DeployCamera(ply, cameraClass)
    -- Check player hasnt got camera limit
    local count = 0
    for k, v in pairs(PerfectCams.Cameras) do
        if (v.owner == ply) then
            count = count + 1
        end
    end

    if (count >= PerfectCams.Config.MaxCameras) then
        PerfectCams.Core.Msg(ply, PerfectCams.Translation.Chat.MaxCameras)
        return false
    end

    local camera = ents.Create(cameraClass.CameraEntClass)
    local origin = cameraClass:CalcOrigin(camera, ply)
    if (!IsValid(camera)) then return false end

    -- We do this after creating so we can get the origin
    if (ply:GetPos():DistToSqr(origin.pos) > PerfectCams.Config.MaxDeployDistance) then
        camera:Remove()
        return false
    end

    local actualCam = PerfectCams.Core.CreateCamera(cameraClass.CameraEntClass, origin.pos, origin.ang, nil, ply)

    camera:Remove()

    return actualCam
end

function PerfectCams.Core.CreateCamera(class, pos, ang, name, ply, group)
    local camera = ents.Create(class)
    if (!IsValid(camera)) then return end
	camera:SetPos(pos)
	camera:SetAngles(ang)

    camera:SetOwner(ply)
    camera:Setowning_ent(ply)
    
    camera:Spawn()

    if (group) then
        camera.IsPerma = true
    end

	local phys = camera:GetPhysicsObject()
	if not IsValid(phys) then return end
	phys:EnableMotion(false)
    
    if (IsValid(ply) and !PerfectCams.Share[ply:SteamID64()]) then
        PerfectCams.Share[ply:SteamID64()] = {
            [ply:SteamID64()] = true
        }
    end

    PerfectCams.Cameras[camera:EntIndex()] = {
        ent = camera,
        name = name or 'Name',
        owner = ply,
        group = group,
        access = IsValid(ply) and PerfectCams.Share[ply:SteamID64()] or {}
    }

    if (group) then
        for k, v in ipairs(player.GetAll()) do
            if (PerfectCams.Config.PermaCameras.Groups[group].canAccess(v)) then
                PerfectCams.Cameras[camera:EntIndex()].access[v:SteamID64()] = true

                net.Start("pCams:Camera:Created")
                    net.WriteUInt(camera:EntIndex(), 16)
                    net.WriteString(PerfectCams.Cameras[camera:EntIndex()].name)
                net.Send(v)
            end
        end
    else
        for k, v in pairs(PerfectCams.Cameras[camera:EntIndex()].access) do
            local target = player.GetBySteamID64(k)
            PerfectCams.Core.GiveSurveillanceMonitor(target, true)
    
            net.Start("pCams:Camera:Created")
                net.WriteUInt(camera:EntIndex(), 16)
                net.WriteString(PerfectCams.Cameras[camera:EntIndex()].name)
            net.Send(target)
        end
    end

    return camera
end

function PerfectCams.Core.GiveSurveillanceMonitor(ply, force)
    if (!PerfectCams.Config.AutoSurveillance) then return end

    // Already has a surveillance monitor
    if (IsValid(ply:GetWeapon('pcams_mobile'))) then return end

    if (force) then
        ply:Give('pcams_mobile')
        return
    end

    // Check to see if they have access to any cameras
    for k, v in pairs(PerfectCams.Cameras) do
        if (v.access[ply:SteamID64()]) then
            ply:Give('pcams_mobile')
            return
        end
    end
end

// May need to use PlayerSpawn instead?
hook.Add("PlayerLoadout", "pCams:PlayerSpawn", function(ply)
    PerfectCams.Core.GiveSurveillanceMonitor(ply)
end)

-- Add cameras to PVS
hook.Add("SetupPlayerVisibility", "pCams:AddCameraPVS", function(ply, viewEntity)
	for k, v in pairs(PerfectCams.Cameras) do
        if not IsValid(v.ent) then continue end
        if v.ent:TestPVS(ply) then continue end

        if not v.access[ply:SteamID64()] then continue end

        AddOriginToPVS(v.ent:GetPos())
    end
end)

// Un/assign perma cameras on job change
hook.Add("OnPlayerChangedTeam", "pCams:JobChange", function(ply, old, new)
    for k, v in pairs(PerfectCams.Cameras) do
        if (!v.group) then continue end

        local access = PerfectCams.Config.PermaCameras.Groups[v.group].canAccess(ply)
    
        // Remove access from user
        if (access) then
            PerfectCams.Cameras[v.ent:EntIndex()].access[ply:SteamID64()] = true

            net.Start("pCams:Camera:Created")
                net.WriteUInt(v.ent:EntIndex(), 16)
                net.WriteString(v.name)
            net.Send(ply)
        else
            PerfectCams.Cameras[v.ent:EntIndex()].access[ply:SteamID64()] = nil

            net.Start("pCams:Camera:Removed")
                net.WriteUInt(v.ent:EntIndex(), 16)
            net.Send(ply)
        end
    end
end)

hook.Add("PlayerDisconnected", "pCams:PlayerDisconnect", function(ply)
    // Remove all cameras
    for k, v in pairs(PerfectCams.Cameras) do
        if (v.group) then continue end
        if (v.owner != ply) then continue end
        
        v.ent:Remove()
        PerfectCams.Cameras[k] = nil
    end

    // Clear any cache data
    PerfectCams.Share[ply:SteamID64()] = {}
end)

net.Receive("pCams:Phone:LinkT:Cast", function(_, ply)
    if PerfectCams.Cooldown.Check('LinkT:Cast', 1, ply) then return end

    local tv = net.ReadEntity()
    local camera = net.ReadEntity()

    if not IsValid(tv) or not IsValid(camera) then return end

    local cameraData = PerfectCams.Cameras[camera:EntIndex()]
    if (not cameraData) then return end

    if (not cameraData.access[ply:SteamID64()]) then return end

    if (tv:GetPos():DistToSqr(ply:GetPos()) > PerfectCams.Config.LinkT.ShareDistance) then return end

    tv:SetCamera(camera)
end)

net.Receive("pCams:Phone:Share", function(_, ply)
    if PerfectCams.Cooldown.Check('Phone:Share', 0.3, ply) then return end

    if (!PerfectCams.Share[ply:SteamID64()]) then
        PerfectCams.Share[ply:SteamID64()] = {}
    end

    local target = net.ReadString()
    local access = net.ReadBool()

    local targetPly = player.GetBySteamID64(target)

    if (not targetPly) then return end
    if (targetPly == ply) then return end

    if (access) then
        PerfectCams.Share[ply:SteamID64()][target] = true
        PerfectCams.Core.GiveSurveillanceMonitor(targetPly, true)
    else
        PerfectCams.Share[ply:SteamID64()][target] = nil
    end

    // Update the access
    for k, v in pairs(PerfectCams.Cameras) do
        if (v.owner != ply) then continue end

        PerfectCams.Cameras[v.ent:EntIndex()].access = PerfectCams.Share[v.owner:SteamID64()]
    
        // Remove access from user
        if (access) then
            net.Start("pCams:Camera:Created")
                net.WriteUInt(v.ent:EntIndex(), 16)
                net.WriteString(v.name)
            net.Send(targetPly)
        else
            net.Start("pCams:Camera:Removed")
                net.WriteUInt(v.ent:EntIndex(), 16)
            net.Send(targetPly)
        end
    end
end)

net.Receive('pCams:Camera:Name', function(_, ply)
    if PerfectCams.Cooldown.Check('Camera:Name', 1, ply) then return end

    local cameraId = net.ReadUInt(16)
    local name = net.ReadString()

    local camera = ents.GetByIndex(cameraId)

    if (!IsValid(camera)) then return end

    local cameraData = PerfectCams.Cameras[camera:EntIndex()]

    if (not cameraData) then return end
    if (cameraData.owner != ply) then return end

    cameraData.name = string.sub(name, 1, 32)

    for k, v in pairs(cameraData.access) do
        local target = player.GetBySteamID64(k)

        net.Start("pCams:Camera:Created")
            net.WriteUInt(camera:EntIndex(), 16)
            net.WriteString(cameraData.name)
        net.Send(target)
    end
end)


net.Receive('pCams:Camera:Action', function(_, ply)
    if PerfectCams.Cooldown.Check('Camera:Action', 0.2, ply) then return end

    local cameraId = net.ReadUInt(16)
    local action = net.ReadUInt(4)

    local camera = ents.GetByIndex(cameraId)

    if (!IsValid(camera)) then return end

    local cameraData = PerfectCams.Cameras[camera:EntIndex()]

    if (not cameraData) then return end
    if (not cameraData.access[ply:SteamID64()]) then return end

    if (action == PerfectCams.ENUM.LEFT and cameraData.ent.ActionLeft) then
        cameraData.ent:ActionLeft()
    elseif (action == PerfectCams.ENUM.RIGHT and cameraData.ent.ActionRight) then
        cameraData.ent:ActionRight()
    elseif (action == PerfectCams.ENUM.UP and cameraData.ent.ActionUp) then
        cameraData.ent:ActionUp()
    elseif (action == PerfectCams.ENUM.DOWN and cameraData.ent.ActionDown) then
        cameraData.ent:ActionDown()
    elseif (action == PerfectCams.ENUM.PRIMARY and cameraData.ent.ActionPrimary) then
        cameraData.ent:ActionPrimary()
    end
end)

net.Receive('pCams:Store:Buy', function(_, ply)
    if PerfectCams.Cooldown.Check('Camera:Action', 0.5, ply) then return end

    local npc = net.ReadEntity()
    local item = net.ReadUInt(5)

    if (not IsValid(npc)) then return end
    if (npc:GetClass() != 'pcams_store_npc') then return end

	if ply:GetPos():Distance(npc:GetPos()) > 300 then return end

    local itemData = PerfectCams.Config.Store.Items[item]

    if (not itemData) then return end

    if (itemData.canPurchase and !itemData.canPurchase(ply)) then return end

    if (!PerfectCams.Config.Store.CanAfford(ply, itemData.price)) then return end

    PerfectCams.Config.Store.TakeMoney(ply, itemData.price)
    PerfectCams.Core.Msg(ply, PerfectCams.Translation.NPC.PurchaseComplete)

    if (itemData.entity) then
        local ent = ents.Create(itemData.class)
        ent:SetPos(npc:GetPos() + (npc:GetForward() * 3) + (npc:GetUp() * 3))
        ent:Setowning_ent(ply)
        ent:SetOwner(ply)
        ent:Spawn()
    else
        local exists = ply:GetWeapon(itemData.class)

        if (IsValid(exists) and exists.PlaceCount) then
            exists.PlaceCount = exists.PlaceCount + 1
            exists:SetClip2(exists.PlaceCount)
        else
            ply:Give(itemData.class)
        end
    end
end)

net.Receive('pCams:Tools:RefreshCameras', function(_, ply)
    // Considering even setting this to a 5 second cooldown?
    if PerfectCams.Cooldown.Check('Tools:RefreshCameras', 2, ply) then return end

    local cams = {}

    for k, v in pairs(PerfectCams.Cameras) do
        if (!v.group) then continue end

        table.insert(cams, {
            name = v.name,
            group = v.group,
            entIndex = k
        })
    end

    net.Start('pCams:Tools:GroupCameras')
        net.WriteTable(cams)
    net.Send(ply)
end)

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
