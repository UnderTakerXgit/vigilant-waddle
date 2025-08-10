-- Leak by VoLVeR https://vk.com/darkrp_credorp

local scale = (ScrW() >= 2560 and 2) or (ScrW() / 175 >= 6 and 1) or 0.8

surface.CreateFont('wepsel', {
    size = 22 * scale,
    weight = 300 * scale,
    antialias = true,
    shadow = true,
    blursize = 0,
    font = 'Arial'
})

surface.CreateFont('small', {
    size = 22 * 0.7 * scale,
    weight = 300 * scale,
    antialias = true,
    shadow = true,
    blursize = 0,
    font = 'Arial'
})

local curTab = 0
local curSlot = 1
local alpha = 0
local lastAction = -math.huge
local loadout = {}
local slide = {}
local newinv

hook.Add('CreateMove', 'wepsel', function(cmd)
    if newinv then
        local wep = LocalPlayer():GetWeapon(newinv)

        if wep:IsValid() and LocalPlayer():GetActiveWeapon() ~= wep then
            cmd:SelectWeapon(wep)
        else
            newinv = nil
        end
    end
end)
-- Leak by VoLVeR https://vk.com/darkrp_credorp
local CWeapons = {}

for _, y in pairs(file.Find('scripts/weapon_*.txt', 'MOD')) do
    local t = util.KeyValuesToTable(file.Read('scripts/' .. y, 'MOD'))

    CWeapons[y:match('(.+)%.txt')] = {
        Slot = t.bucket,
        SlotPos = t.bucket_position,
        TextureData = t.texturedata
    }
end

local localization = {
    gmod_camera = 'Камера',
    gmod_tool = 'Tool-gun',
    weapon_physcannon = 'Gravitygun',
    weapon_physgun = 'Physgun'
}

local function findcurrent()
    if alpha <= 0 then
        table.Empty(slide)
        local class = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()

        for k1, v1 in pairs(loadout) do
            for k2, v2 in pairs(v1) do
                if v2.classname == class then
                    curTab = k1
                    curSlot = k2

                    return
                end
            end
        end
    end
end

local function update()
    table.Empty(loadout)

    for k, v in pairs(LocalPlayer():GetWeapons()) do
        local classname = v:GetClass()
        local Slot = CWeapons[classname] and CWeapons[classname].Slot or v.Slot or 1
        loadout[Slot] = loadout[Slot] or {}

        table.insert(loadout[Slot], {
            classname = classname,
            name = localization[classname] or v:GetPrintName(),
            new = (CurTime() - v:GetCreationTime()) < 60,
            slotpos = CWeapons[classname] and CWeapons[classname].SlotPos or v.SlotPos or 1
        })
    end

    for k, v in pairs(loadout) do
        table.sort(v, function(a, b) return a.slotpos < b.slotpos end)
    end
end

local FKeyBinds = {
    ['gm_showhelp'] = 'ShowHelp',
    ['gm_showteam'] = 'ShowTeam',
    ['gm_showspare1'] = 'ShowSpare1',
    ['gm_showspare2'] = 'ShowSpare2'
}
timer.Simple(0, function()
    if not GAMEMODE then return end
function GAMEMODE:PlayerBindPress(ply, bind, pressed)
    self.BaseClass:PlayerBindPress(ply, bind, pressed)
    local bnd = bind:lower():match('gm_[a-z]+[12]?')

    --if bnd and FKeyBinds[bnd] then
        --hook.Call(FKeyBinds[bnd], GAMEMODE)
    --end

    if not pressed or ply:InVehicle() then return end
    bind = bind:lower()

    if bind:sub(1, 4) == 'slot' then
        local n = tonumber(bind:sub(5, 5) or 1) or 1
        if n < 1 or n > 6 then return true end
        n = n - 1
        update()
        if not loadout[n] then return true end
        findcurrent()

        if curTab == n and loadout[curTab] and (alpha > 0 or GetConVarNumber('hud_fastswitch') > 0) then
            curSlot = curSlot + 1

            if curSlot > #loadout[curTab] then
                curSlot = 1
            end
        else
            curTab = n
            curSlot = 1
        end

        if GetConVarNumber('hud_fastswitch') > 0 then
            newinv = loadout[curTab][curSlot].classname
        else
            alpha = 1
            lastAction = RealTime()
        end

        surface.PlaySound('ambient/water/rain_drip1.wav')

        return true
    elseif bind:find('invnext', nil, true) and not (ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == 'weapon_physgun' and ply:KeyDown(IN_ATTACK)) then
        update()
        if #loadout < 1 then return true end
        findcurrent()
        curSlot = curSlot + 1

        if curSlot > (loadout[curTab] and #loadout[curTab] or -1) then
            repeat
                curTab = curTab + 1

                if curTab > 5 then
                    curTab = 0
                end
            until loadout[curTab]
            curSlot = 1
        end

        if GetConVarNumber('hud_fastswitch') > 0 then
            newinv = loadout[curTab][curSlot].classname
            surface.PlaySound('ambient/water/rain_drip3.wav')
        else
            lastAction = RealTime()
            alpha = 1
            surface.PlaySound('ambient/water/rain_drip1.wav')
        end

        return true
    elseif bind:find('invprev', nil, true) and not (ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == 'weapon_physgun' and ply:KeyDown(IN_ATTACK)) then
        update()
        if #loadout < 1 then return true end
        findcurrent()
        curSlot = curSlot - 1

        if curSlot < 1 then
            repeat
                curTab = curTab - 1

                if curTab < 0 then
                    curTab = 5
                end
            until loadout[curTab]
            curSlot = #loadout[curTab]
        end

        if GetConVarNumber('hud_fastswitch') > 0 then
            newinv = loadout[curTab][curSlot].classname
            surface.PlaySound('ambient/water/rain_drip3.wav')
        else
            lastAction = RealTime()
            alpha = 1
            surface.PlaySound('ambient/water/rain_drip1.wav')
        end

        return true
    elseif bind:find('+attack', nil, true) and alpha > 0 then
        if loadout[curTab] and loadout[curTab][curSlot] and not bind:find('+attack2', nil, true) then
            newinv = loadout[curTab][curSlot].classname
        end

        surface.PlaySound('ambient/water/rain_drip3.wav')
        alpha = 0

        return true
    end
end
end)

local width = 175 * scale
local height = 22 * scale
local margin = height / 4
local c000127 = Color(113, 128, 147, 127)
local c00200200 = Color(47, 54, 64, 200)

hook.Add('HUDPaint', 'wepsel', function()
    if not IsValid(LocalPlayer()) then return end

    if alpha < 1e-02 then
        if alpha ~= 0 then
            alpha = 0
        end

        return
    end

    update()

    if RealTime() - lastAction > 2 then
        alpha = Lerp(FrameTime() * 4, alpha, 0)
    end

    surface.SetAlphaMultiplier(alpha)
    surface.SetDrawColor(113, 128, 147)
    surface.SetTextColor(color_white)
    surface.SetFont('wepsel')
    local thisWidth = 0

    for i, v in pairs(loadout) do
        thisWidth = thisWidth + width + margin
    end

    local offx = ScrW() - thisWidth

    for i, v in pairs(loadout) do
        local offy = margin
        surface.SetDrawColor(113, 128, 147)
        surface.DrawRect(offx, offy, height, height)
        local w, h = surface.GetTextSize(i + 1)
        surface.SetTextPos(offx + (height - w) / 2, offy + (height - h) / 2)
        surface.DrawText(i + 1)
        offy = offy + h + margin

        for j, wep in pairs(v) do
            local selected = curTab == i and curSlot == j
            --local height = selected and height * 2 + margin or height
            local height = height + (height + margin) * (slide[wep.classname] or 0)
            slide[wep.classname] = Lerp(FrameTime() * 10, slide[wep.classname] or 0, selected and 1 or 0)
            surface.SetDrawColor(selected and c00200200 or (wep.new and Color(0, math.abs(math.sin(RealTime())) * 255, 215, 0) or c000127))
            surface.DrawRect(offx, offy, width, height)
            surface.SetFont('wepsel')
            local w, h = surface.GetTextSize(wep.name)

            if w > width then
                surface.SetFont('small')
                w, h = surface.GetTextSize(wep.name)
            end

            surface.SetTextPos(offx + (width - w) / 2, offy + (height - h) / 2)
            surface.DrawText(wep.name)
            offy = offy + height + margin
        end

        offx = offx + width + margin
    end

    surface.SetAlphaMultiplier(1)
end)