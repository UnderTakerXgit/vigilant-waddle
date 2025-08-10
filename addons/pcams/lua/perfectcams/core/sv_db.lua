--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

function PerfectCams.Database.Startup()
	if (!sql.TableExists("pcam_ents")) then
		sql.Query([[CREATE TABLE pcam_ents(
            `id` INTEGER PRIMARY KEY AUTOINCREMENT,
            `camera_type` VARCHAR(32) NOT NULL,
            `group` VARCHAR(32) NOT NULL,
            `name` VARCHAR(32) NOT NULL,
            `pos` TEXT,
            `ang` TEXT,
            `map` TEXT
        );]])
	end
	if (!sql.TableExists("pcam_tvs")) then
		sql.Query([[CREATE TABLE pcam_tvs(
            `id` INTEGER PRIMARY KEY AUTOINCREMENT,
            `tv_type` VARCHAR(32) NOT NULL,
            `camera_id` VARCHAR(32) NOT NULL,
            `pos` TEXT,
            `ang` TEXT,
            `map` TEXT
        );]])
	end
end

function PerfectCams.Database.InsertCamera(cameraType, group, name, pos, ang)
    if (!cameraType) then return end
    if (!group) then return end
    if (!name) then return end
    if (!pos) then return end
    if (!ang) then return end

    sql.Query(string.format("INSERT INTO pcam_ents(`camera_type`, `group`, `name`, `pos`, `ang`, `map`) VALUES('%s', '%s', '%s', '%s', '%s', '%s');",
        sql.SQLStr(cameraType, true),
        sql.SQLStr(group, true),
        sql.SQLStr(name, true),
        util.TableToJSON({x = pos.x, y = pos.y, z = pos.z}),
        util.TableToJSON({x = ang.x, y = ang.y, z = ang.z}),
        sql.SQLStr(game.GetMap(), true)
    ))

    return sql.QueryRow("SELECT id FROM pcam_ents ORDER BY id DESC;")
end

function PerfectCams.Database.InsertTV(tvType, cameraId, pos, ang)
    if (!tvType) then return end
    if (!cameraId) then return end
    if (!pos) then return end
    if (!ang) then return end

    sql.Query(string.format("INSERT INTO pcam_tvs(`tv_type`, `camera_id`, `pos`, `ang`, `map`) VALUES('%s', '%s', '%s', '%s', '%s');",
        sql.SQLStr(tvType, true),
        sql.SQLStr(cameraId, true),
        util.TableToJSON({x = pos.x, y = pos.y, z = pos.z}),
        util.TableToJSON({x = ang.x, y = ang.y, z = ang.z}),
        sql.SQLStr(game.GetMap(), true)
    ))

    return sql.QueryRow("SELECT id FROM pcam_tvs ORDER BY id DESC;")
end

function PerfectCams.Database.GetCameraRecords()
	return sql.Query(string.format("SELECT * FROM pcam_ents WHERE map = '%s';", sql.SQLStr(game.GetMap(), true)))
end

function PerfectCams.Database.GetTVRecords()
	return sql.Query(string.format("SELECT * FROM pcam_tvs WHERE map = '%s';", sql.SQLStr(game.GetMap(), true)))
end

function PerfectCams.Database.DeleteCameraByID(id)
	return sql.Query(string.format("DELETE FROM pcam_ents WHERE id = %i;", id))
end


function PerfectCams.Database.DeleteTVByID(id)
	return sql.Query(string.format("DELETE FROM pcam_tvs WHERE id = %i;", id))
end

function PerfectCams.Database.SpawnEnts()
	local cameras = PerfectCams.Database.GetCameraRecords()
    local cameraMap = {}

	if (istable(cameras) and !table.IsEmpty(cameras)) then
        for k, v in pairs(cameras) do
            local pos = util.JSONToTable(v.pos)
            pos = Vector(pos.x, pos.y, pos.z)
    
            local ang = util.JSONToTable(v.ang)
            ang = Angle(ang.x, ang.y, ang.z)
    
            local camera = PerfectCams.Core.CreateCamera(v.camera_type, pos, ang, v.name, NULL, v.group)
            camera.DatabaseId = v.id
            cameraMap[v.id] = camera
        end
    end
	

	local TVs = PerfectCams.Database.GetTVRecords()
	
	if (istable(TVs) and !table.IsEmpty(TVs)) then
        for k, v in pairs(TVs) do
            local pos = util.JSONToTable(v.pos)
            pos = Vector(pos.x, pos.y, pos.z)
    
            local ang = util.JSONToTable(v.ang)
            ang = Angle(ang.x, ang.y, ang.z)
    
            local tv = ents.Create(v.tv_type)
            if (!IsValid(tv)) then continue end
            tv:SetPos(pos)
            tv:SetAngles(ang)
            tv:Spawn()
            local phys = tv:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end

            if (cameraMap[v.camera_id]) then
                tv:SetCamera(cameraMap[v.camera_id])
            end

            tv.DatabaseId = v.id
        end
    end
end

hook.Add("InitPostEntity", "pCams:Database:Init", function()
	PerfectCams.Database.Startup()
    PerfectCams.Database.SpawnEnts()
end)

hook.Add("PostCleanupMap", "pCams:Database:PostCleanup", function()
	PerfectCams.Database.SpawnEnts()
end)

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
