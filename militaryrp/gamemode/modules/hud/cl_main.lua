
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local surface = surface
local ipairs = ipairs
local tostring = tostring
local string = string
local Material = Material
local Lerp = Lerp
local FrameTime = FrameTime
local Color = Color
local draw = draw
local math = math
local GetConVar = GetConVar
local hook = hook
local ScrW = ScrW
local ScrH = ScrH
local CurTime = CurTime
local CreateMaterial = CreateMaterial
local pairs = pairs
local ents = ents

local W, H = ScrW, ScrH
local alpha = 0
local cur_alpha = 0
local info_alpha = 255
local cur_info_alpha = 0
local cur_hp = IsValid(LocalPlayer()) and LocalPlayer():Health() or 0
local cur_armor = IsValid(LocalPlayer()) and LocalPlayer():Armor() or 0
-- Leak by VoLVeR https://vk.com/darkrp_credorp
local function DrawFlexText(colors, font, x, y)
    surface.SetFont(font)
    surface.SetTextPos(x, y)

    for k, v in ipairs(colors) do
        local col = v[2]
        surface.SetTextColor(col.r, col.g, col.b, col.a or 255)
        surface.DrawText(tostring(v[1]) .. (v[3] and '' or ' '))
    end
end

local function simpleSum(num)
    local k = 0

    while num * 0.001 >= 1 do
        k = k + 1
        num = num * 0.001
    end

    return string.sub(num, 1, 3) .. string.rep('k', k)
end

local gap = 15
local HealthMat = Material('icon16/heart.png', 'mips')
local ArmorMat = Material('icon16/shield.png', 'mips')

hook.Add('NextRP::IconLoaded', 'NextRP::LoadHUDIcons', function()
    HealthMat = NextRP.Style.Materials.Health
    ArmorMat = NextRP.Style.Materials.Armor
end)

local function hud()
    if not LocalPlayer():Alive() then return end
    cur_alpha = Lerp(FrameTime() * 12, cur_alpha, alpha)
    cur_info_alpha = Lerp(FrameTime() * 12, cur_info_alpha, info_alpha)

    if cur_hp ~= LocalPlayer():Health() then
        cur_hp = Lerp(FrameTime() * 12, cur_hp, LocalPlayer():Health())
    end

    if cur_armor ~= LocalPlayer():Armor() then
        cur_armor = Lerp(FrameTime() * 12, cur_armor, LocalPlayer():Armor())
    end

    surface.SetDrawColor(255, 94, 87, cur_info_alpha)
    draw.NoTexture()






    surface.SetDrawColor(128, 128, 128, 0)
  --  surface.SetMaterial(NextRP.Style.Materials.LogoWatermark)
    surface.DrawTexturedRect(W() - 32, H() - 28, 32, 32)
    draw.DrawText('Rephyx.tech' .. ' v. ' .. '1.0.1d', 'font_sans_16', W() - 32, H() - 20, Color(240, 240, 240, 15), TEXT_ALIGN_RIGHT)

    local t = {
        {'Рация', Color(240, 240, 240, 250)}
    }

    if LocalPlayer():GetSpeaker() then
        t[#t + 1] = {'включена', NextRP.Style.Theme.Green, true}

        t[#t + 1] = {', частота:', Color(240, 240, 240, 250)}

        t[#t + 1] = {tostring(LocalPlayer():GetFrequency()), NextRP.Style.Theme.Accent}
    else
        t[#t + 1] = {'выключена', NextRP.Style.Theme.LightRed, true}
        t[#t + 1] = {'.', NextRP.Style.Theme.Text, true}
    end

    DrawFlexText(t, 'font_sans_16', 9, 5)
end

-- Отрисовка худа
local hide = GetConVar('cl_drawhud')

hook.Add('HUDPaint', 'NextRP::DrawCustomHUD', function()
    if not hide:GetBool() then return end
    hud()
end)
-- Leak by VoLVeR https://vk.com/darkrp_credorp
-- Прячем стандартные элементы
local HiddenElements = {
    DarkRP_HUD = true,
    DarkRP_EntityDisplay = true,
    DarkRP_ZombieInfo = true,
    DarkRP_LocalPlayerHUD = true,
    DarkRP_Hungermod = true,
    DarkRP_Agenda = true,
    CHudAmmo = true,
    CHudHealth = true,
    CHudBattery = true,
    CHudSuitPower = true,
    CHudDeathNotice = true,
    CHudDamageIndicator = true,
    CHudPoisonDamageIndicator = true,
    CHudZoom = true
}

hook.Add('HUDShouldDraw', 'NextRP::HideDefaultHUDElements', function(e)
    if (HiddenElements[e]) then return false end
end)

hook.Add('HUDDrawTargetID', 'NextRP::HideDrawTarget', function() return false end)
hook.Add('DrawDeathNotice', 'NextRP::HideDrawDeath', function() return 0, 0 end)

hook.Add('PlayerButtonDown', 'HUDButtonDown', function(pPlayer, kNum)
    if kNum == KEY_T then
        alpha = 0
        info_alpha = 255
    end
end)

hook.Add('PlayerButtonUp', 'HUDButtonUp', function(pPlayer, kNum)
    if kNum == KEY_T then
        alpha = 0
        info_alpha = 255
    end
end)

local highlight_disabled = true
local disabled = false
local user_disabled = false
local mathrad = math.rad
local mathsin = math.sin
local mathcos = math.cos
local tableinsert = table.insert
local surfaceDrawPoly = surface.DrawPoly
local surfaceDrawRect = surface.DrawRect
local render = render

local function drawhCircle(x, y, radius, seg, ang, nml)
    ang = ang or 360
    nml = nml or 0
    nml = mathrad(nml)
    local cir = {}

    tableinsert(cir, {
        x = x,
        y = y,
        u = 0.5,
        v = 0.5
    })

    for i = 0, seg do
        local a = mathrad((i / seg) * -ang) + nml
        local sin, cos = mathsin(a), mathcos(a)

        tableinsert(cir, {
            x = x + sin * radius,
            y = y + cos * radius,
            u = sin / 2 + 0.5,
            v = cos / 2 + 0.5
        })
    end

    local sin, cos = mathsin(nml), mathcos(nml)

    tableinsert(cir, {
        x = x + sin * radius,
        y = y + cos * radius,
        u = sin / 2 + 0.5,
        v = cos / 2 + 0.5
    })

    surfaceDrawPoly(cir)
end

local lastupdate = 0
local updatetime = 1
local scrw, scrh = ScrW(), ScrH()
local cen_x, cen_y = scrw / 2, scrh / 2

local leftPoly = {
    {
        x = cen_x - 530,
        y = cen_y + 220
    },
    {
        x = cen_x - 190,
        y = cen_y + 220
    },
    {
        x = cen_x - 250,
        y = cen_y + 309
    },
    {
        x = cen_x - 530,
        y = cen_y + 310
    }
}

local rightPoly = {
    {
        x = cen_x + 190,
        y = cen_y + 220
    },
    {
        x = cen_x + 530,
        y = cen_y + 220
    },
    {
        x = cen_x + 530,
        y = cen_y + 310
    },
    {
        x = cen_x + 250,
        y = cen_y + 309
    }
}

hook.Add('PostDrawHUD', 'Cloakers_uniquely_named_hook', function()
    if lastupdate < CurTime() then
        if (scrw ~= ScrW() or scrh ~= ScrH()) then
            scrw = ScrW()
            scrh = ScrH()
        end

        lastupdate = CurTime() + updatetime
    end

    if not (LocalPlayer():KeyDown(IN_ZOOM)) then return end
    -- Tell Garry no, aka cleanup after him
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()
    render.SetStencilEnable(true)
    draw.NoTexture()
    -- TRANSPARENCY
    surface.SetDrawColor(255, 255, 255, 255)
    drawhCircle(cen_x - 530, cen_y, 310, 80)
    drawhCircle(cen_x + 530, cen_y, 310, 80)
    surfaceDrawPoly(leftPoly)
    surfaceDrawPoly(rightPoly)
    surfaceDrawRect(cen_x - 530, cen_y - 310, 1060, 530)
    surfaceDrawRect(cen_x - 50, cen_y + 290, 100, 15)
    surfaceDrawRect(cen_x - 120, cen_y + 290, 60, 15)
    surfaceDrawRect(cen_x + 62, cen_y + 290, 60, 15)
    -- FLOATING BITS
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    surface.SetDrawColor(0, 0, 0, 255)
    surfaceDrawRect(cen_x - 320, cen_y - 370, 3, 740)
    surfaceDrawRect(cen_x + 320, cen_y - 370, 3, 740)
    surfaceDrawRect(cen_x - 60, cen_y - 1, 120, 2)
    surfaceDrawRect(cen_x, cen_y - 30, 2, 60)
    surfaceDrawRect(cen_x - 270, cen_y - 165, 80, 7)
    surfaceDrawRect(cen_x - 270, cen_y - 150, 80, 7)
    surfaceDrawRect(cen_x - 270, cen_y - 135, 80, 7)
    surface.SetDrawColor(20, 20, 20, 255)
    drawhCircle(cen_x - 200, cen_y, 50, 40, 180, 0)
    drawhCircle(cen_x + 200, cen_y, 50, 40, 180, 180)
    surface.SetDrawColor(255, 255, 255, 255)
    drawhCircle(cen_x - 204, cen_y + 4, 40, 40, 90, 0)
    drawhCircle(cen_x - 204, cen_y - 4, 40, 40, 90, 270)
    drawhCircle(cen_x + 204, cen_y - 4, 40, 40, 90, 180)
    drawhCircle(cen_x + 204, cen_y + 4, 40, 40, 90, 90)
    surfaceDrawRect(cen_x - 50, cen_y + 290, 100, 15)
    surfaceDrawRect(cen_x - 120, cen_y + 290, 60, 15)
    surfaceDrawRect(cen_x + 62, cen_y + 290, 60, 15)
    dist = math.floor((LocalPlayer():GetEyeTrace().HitPos - LocalPlayer():GetPos()):Length())
    local bearing = math.Round(360 - (LocalPlayer():GetAngles().y % 360))
    draw.DrawText(dist, 'font_sans_21', cen_x, cen_y + 287, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
    draw.DrawText(bearing, 'font_sans_16', cen_x + 62 + 30, cen_y + 290, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
    render.SetStencilCompareFunction(STENCIL_GREATER)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    surface.SetDrawColor(0, 0, 0, 255)
    surfaceDrawRect(-1, -1, scrw + 1, scrh + 1)
    render.SetStencilEnable(false)
end)

local flir_whitehot = CreateMaterial('flir_whitehot_mat', 'UnlitGeneric', {
    ['$basetexture'] = 'models/debug/debugwhite',
    ['$color'] = '{ 255 255 255 }'
})

hook.Add('PostDrawOpaqueRenderables', 'flir_drawhighlight', function()
    if (highlight_disabled) then return end
    if not (LocalPlayer():KeyDown(IN_ZOOM)) then return end
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilReferenceValue(1)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.OverrideDepthEnable(true, false)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    -- Pixels drawn that can be seen will be drawn
    -- otherwise they will be left the same
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilPassOperation(STENCIL_REPLACE)

    for key, prop in pairs(ents.GetAll()) do
        local class = prop:GetClass()

        if (prop:IsPlayer() or class:find('npc_')) then
            if (prop:GetMaterial() == 'models/effects/vol_light001' or prop:GetNoDraw()) then continue end
            prop:DrawModel()
        end
    end

    render.OverrideDepthEnable(false, false)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetMaterial(flir_whitehot)
    render.DrawScreenQuad()
    render.SetStencilEnable(false)
end)