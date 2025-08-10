if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Электрошокер"
SWEP.Author = "Custom GMOD Dev"
SWEP.Instructions = "ЛКМ — оглушить цель"
SWEP.Category = "!Rephyx.tech | Оружие"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
SWEP.UseHands = true
SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary = SWEP.Primary

local STUN_TIME = 10 -- секунды оглушения

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)

    self:EmitSound("weapons/stunstick/stunstick_swing1.wav")
    self:SendWeaponAnim(ACT_VM_HITCENTER)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        local tr = self.Owner:GetEyeTrace()
        local ent = tr.Entity

        if IsValid(ent) and ent:IsPlayer() and ent:GetPos():DistToSqr(self.Owner:GetPos()) < 100 * 100 then
            self:StunPlayer(ent)
        end
    end
end

-- Основная логика оглушения
function SWEP:StunPlayer(target)
    if not target.NextStun or target.NextStun < CurTime() then
        target.NextStun = CurTime() + STUN_TIME + 2

        -- Показать визуальный эффект на экране жертвы
        netstream.Start(target, "NextRP::StunScreen", true, self.Owner, STUN_TIME)

        -- Проигрываем звук ОТ жертвы, слышен всем рядом
        target:EmitSound("npc/vort/attack_shoot.wav", 75, 100, 1, CHAN_AUTO)

        -- Запускаем эффект Tesla вокруг жертвы на 10 секунд
        local effectTimerID = "TeslaEffect_" .. target:EntIndex()
        timer.Create(effectTimerID, 0.2, STUN_TIME / 0.2, function()
            if not IsValid(target) then
                timer.Remove(effectTimerID)
                return
            end

            local tesla = ents.Create("point_tesla")
            if not IsValid(tesla) then return end

            tesla:SetPos(target:GetPos() + Vector(0, 0, 50))
            tesla:SetKeyValue("m_SoundName", "DoSpark")
            tesla:SetKeyValue("texture", "sprites/physbeam.vmt")
            tesla:SetKeyValue("m_Color", "255 255 255")
            tesla:SetKeyValue("m_flRadius", "100")
            tesla:SetKeyValue("beamcount_min", "4")
            tesla:SetKeyValue("beamcount_max", "8")
            tesla:SetKeyValue("thick_min", "2")
            tesla:SetKeyValue("thick_max", "4")
            tesla:SetKeyValue("lifetime_min", "0.1")
            tesla:SetKeyValue("lifetime_max", "0.2")
            tesla:SetKeyValue("interval_min", "0.1")
            tesla:SetKeyValue("interval_max", "0.2")

            tesla:Spawn()
            tesla:Fire("DoSpark", "", 0)
            tesla:Fire("Kill", "", 0.3)
        end)

        -- Отключаем управление жертве
        target:Freeze(true)
        target:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_WALK_ZOMBIE_01, true)

        -- Через STUN_TIME убираем эффект и возвращаем управление
        timer.Simple(STUN_TIME, function()
            if IsValid(target) then
                netstream.Start(target, "NextRP::StunScreen", false)
                target:Freeze(false)
                target:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
            end
            timer.Remove(effectTimerID)
        end)
    end
end
