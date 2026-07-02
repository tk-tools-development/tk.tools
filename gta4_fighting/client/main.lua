-- GTA IV Style Fighting System - Main Combat Controller
--
-- Controls (defaults, configurable in config.lua):
--   Right-click / LT   - Lock on to target & enter combat stance
--   Left-click  / RT   - Punch (chains into 4-hit combo)
--   Shift + Attack      - Heavy punch
--   Left Ctrl           - Dodge / weave (direction-based)
--   E                   - Finisher (when target is low HP)
--   F11                 - Toggle system on/off
--
--   While locked on, hold right-click to block; release to exit combat.
--   Block just as you get hit, then quickly attack to counter.

local playerPed       = nil
local isInCombat      = false
local comboIndex      = 1
local lastPunchTime   = 0
local lastDodgeTime   = 0
local isBlocking      = false
local isDodging       = false
local isPunching      = false
local isSystemEnabled = true
local finisherShown   = false

------------------------------------------------------------------------
-- Main loop
------------------------------------------------------------------------
Citizen.CreateThread(function()
    Anims.LoadAll()

    while true do
        Citizen.Wait(0)
        playerPed = PlayerPedId()

        if not isSystemEnabled then
            Citizen.Wait(500)
            goto continue
        end

        if IsEntityDead(playerPed) or IsPedInAnyVehicle(playerPed, false) then
            if isInCombat then ExitCombat() end
            Citizen.Wait(500)
            goto continue
        end

        local isUnarmed = (GetSelectedPedWeapon(playerPed) == GetHashKey("WEAPON_UNARMED"))
        if not isUnarmed then
            if isInCombat then ExitCombat() end
            Citizen.Wait(100)
            goto continue
        end

        local playerCoords = GetEntityCoords(playerPed)
        HandleCombatInput(playerCoords)
        HandleTargeting(playerCoords)
        HandleCombatMovement()
        Targeting.DrawReticle()

        ::continue::
    end
end)

------------------------------------------------------------------------
-- Toggle key
------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, Config.ToggleKey) then
            isSystemEnabled = not isSystemEnabled
            if isSystemEnabled then
                Notify("~g~GTA IV Fighting: ~w~Enabled")
                Anims.LoadAll()
            else
                Notify("~r~GTA IV Fighting: ~w~Disabled")
                ExitCombat()
                Anims.UnloadAll()
            end
        end
    end
end)

------------------------------------------------------------------------
-- Disable default melee while our system is active
------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isSystemEnabled and isInCombat then
            DisableControlAction(0, 24,  true) -- Attack
            DisableControlAction(0, 25,  true) -- Aim
            DisableControlAction(0, 140, true) -- Melee light
            DisableControlAction(0, 141, true) -- Melee heavy
            DisableControlAction(0, 142, true) -- Melee alt
            DisableControlAction(0, 143, true) -- Melee
            DisableControlAction(0, 263, true) -- Melee 1
            DisableControlAction(0, 264, true) -- Melee 2
        end
    end
end)

------------------------------------------------------------------------
-- Input handler
------------------------------------------------------------------------
function HandleCombatInput(playerCoords)
    local now = GetGameTimer()

    -- Enter combat / lock on (right-click)
    if IsDisabledControlJustPressed(0, 25) or IsControlJustPressed(0, 25) then
        if not isInCombat then
            EnterCombat(playerCoords)
        end
    end

    -- Release lock-on -> exit combat
    if IsDisabledControlJustReleased(0, 25) or IsControlJustReleased(0, 25) then
        if isInCombat and not isPunching then
            ExitCombat()
        end
    end

    if not isInCombat then return end

    -- Punch (left-click, disabled control)
    if IsDisabledControlJustPressed(0, 24) and not isPunching and not isDodging and not isBlocking then
        local dt = now - lastPunchTime
        if dt > Config.ComboCooldown then comboIndex = 1 end
        if dt > Config.PunchCooldown then
            if IsControlPressed(0, Config.HeavyAttackKey) then
                ThrowHeavyPunch()
            else
                ThrowPunch()
            end
            lastPunchTime = now
        end
    end

    -- Block (hold right-click while in combat)
    if isInCombat and (IsDisabledControlPressed(0, 25) or IsControlPressed(0, 25)) then
        if not isBlocking and not isPunching and not isDodging then
            StartBlock()
        end
    elseif isBlocking then
        StopBlock()
    end

    -- Dodge (Ctrl + movement direction)
    if IsControlJustPressed(0, Config.DodgeKey) and not isDodging and not isPunching then
        if (now - lastDodgeTime) > Config.DodgeCooldown then
            PerformDodge()
            lastDodgeTime = now
        end
    end
end

------------------------------------------------------------------------
-- Targeting upkeep
------------------------------------------------------------------------
function HandleTargeting(playerCoords)
    if not isInCombat then return end
    Targeting.ValidateTarget(playerCoords)
    if Targeting.IsLockedOn then Targeting.FaceTarget(playerPed) end
end

------------------------------------------------------------------------
-- Slower movement while in combat stance
------------------------------------------------------------------------
function HandleCombatMovement()
    if not isInCombat then return end
    if not isPunching and not isDodging then
        SetPedMoveRateOverride(playerPed, Config.MovementSlowdown)
    end
end

------------------------------------------------------------------------
-- Enter / exit combat
------------------------------------------------------------------------
function EnterCombat(playerCoords)
    isInCombat = true
    comboIndex = 1

    RequestClipSet(Config.FightingStanceClipset)
    local t = 100
    while not HasClipSetLoaded(Config.FightingStanceClipset) and t > 0 do
        Citizen.Wait(10)
        t = t - 1
    end
    SetPedMovementClipset(playerPed, Config.FightingStanceClipset, 0.5)

    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
    SetPedConfigFlag(playerPed, 292, true)

    local target, dist = Targeting.FindTarget(playerPed, playerCoords)
    if target and dist <= Config.LockOnSearchRange then
        Targeting.LockOn(target)
    end
end

function ExitCombat()
    isInCombat  = false
    isBlocking  = false
    isDodging   = false
    isPunching  = false
    comboIndex  = 1

    ResetPedMovementClipset(playerPed, 0.5)
    SetPedMoveRateOverride(playerPed, 1.0)
    Targeting.Release()
    ClearPedTasks(playerPed)
end

------------------------------------------------------------------------
-- Punch (combo chain)
------------------------------------------------------------------------
function ThrowPunch()
    isPunching = true

    local anim = Anims.PunchCombo[comboIndex]
    if not anim then
        comboIndex = 1
        anim = Anims.PunchCombo[1]
    end

    if not Anims.EnsureDict(anim.dict) then isPunching = false return end

    if Targeting.IsLockedOn then Targeting.FaceTarget(playerPed) end
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, anim.dict, anim.name,
        anim.blendIn, anim.blendOut, anim.duration, 49, 0, false, false, false)

    local damageDelay = math.floor(anim.duration * anim.damageFrame)
    Citizen.SetTimeout(damageDelay, function()
        ApplyPunchHit(anim)
    end)

    Citizen.SetTimeout(anim.duration, function()
        isPunching = false
    end)

    comboIndex = comboIndex + 1
    if comboIndex > #Anims.PunchCombo then comboIndex = 1 end
end

------------------------------------------------------------------------
-- Heavy punch
------------------------------------------------------------------------
function ThrowHeavyPunch()
    isPunching = true

    local anim = Anims.HeavyPunch[math.random(1, #Anims.HeavyPunch)]
    if not Anims.EnsureDict(anim.dict) then isPunching = false return end

    if Targeting.IsLockedOn then Targeting.FaceTarget(playerPed) end
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, anim.dict, anim.name,
        anim.blendIn, anim.blendOut, anim.duration, 49, 0, false, false, false)

    local damageDelay = math.floor(anim.duration * anim.damageFrame)
    Citizen.SetTimeout(damageDelay, function()
        ApplyPunchHit(anim)
    end)

    Citizen.SetTimeout(anim.duration, function()
        isPunching = false
    end)

    comboIndex = 1
end

------------------------------------------------------------------------
-- Shared hit logic
------------------------------------------------------------------------
function ApplyPunchHit(anim)
    if not Targeting.IsLockedOn or not Targeting.CurrentTarget then return end
    local dist = Targeting.GetTargetDistance(GetEntityCoords(playerPed))
    if dist > Config.LockOnRange then return end

    local damage    = Config.PunchDamage[anim.type] or Config.PunchDamage.light
    local intensity = Effects.GetIntensity(anim.type)

    Effects.ApplyDamage(Targeting.CurrentTarget, damage)
    Effects.CameraShake(intensity.shake)
    Effects.Knockback(Targeting.CurrentTarget, playerPed, intensity.knockback)
    Effects.PunchSound(Targeting.CurrentTarget, anim.type)
    PlayHitReaction(Targeting.CurrentTarget, anim.type)

    if intensity.stagger > 0 then
        Effects.Stagger(Targeting.CurrentTarget, intensity.stagger)
    end
    if intensity.flash then Effects.ScreenFlash() end
    if intensity.slowmo then Effects.SlowMotion() end

    local tc = GetEntityCoords(Targeting.CurrentTarget)
    Effects.ImpactParticle(tc + vector3(0.0, 0.0, 0.6))
end

------------------------------------------------------------------------
-- Hit reactions on target
------------------------------------------------------------------------
function PlayHitReaction(targetPed, hitType)
    if not DoesEntityExist(targetPed) or IsEntityDead(targetPed) then return end
    local pool = Anims.HitReactions[hitType] or Anims.HitReactions.light
    local r = pool[math.random(1, #pool)]
    if Anims.EnsureDict(r.dict) then
        TaskPlayAnim(targetPed, r.dict, r.name,
            r.blendIn, r.blendOut, r.duration, 33, 0, false, false, false)
    end
end

------------------------------------------------------------------------
-- Block / counter
------------------------------------------------------------------------
function StartBlock()
    isBlocking = true
    local a = Anims.Block.enter
    if Anims.EnsureDict(a.dict) then
        TaskPlayAnim(playerPed, a.dict, a.name,
            a.blendIn, a.blendOut, -1, 49, 0, false, false, false)
    end
    SetPedSuffersCriticalHits(playerPed, false)
end

function StopBlock()
    isBlocking = false
    ClearPedTasks(playerPed)
    SetPedSuffersCriticalHits(playerPed, true)
end

-- Detect hits while blocking -> open counter window
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if isInCombat and isBlocking and not isPunching then
            if HasEntityBeenDamagedByAnyPed(playerPed) then
                ClearEntityLastDamageEntity(playerPed)

                local bh = Anims.Block.hit
                if Anims.EnsureDict(bh.dict) then
                    TaskPlayAnim(playerPed, bh.dict, bh.name,
                        bh.blendIn, bh.blendOut, bh.duration, 49, 0, false, false, false)
                end
                Effects.CameraShake(0.08)

                -- Counter window
                local windowOpen = true
                Citizen.SetTimeout(Config.CounterWindow, function() windowOpen = false end)
                Citizen.CreateThread(function()
                    while windowOpen do
                        Citizen.Wait(0)
                        if IsDisabledControlJustPressed(0, 24) then
                            PerformCounter()
                            windowOpen = false
                        end
                    end
                end)
            end
        end
    end
end)

function PerformCounter()
    isPunching = true
    isBlocking = false

    local anim = Anims.Counter
    if not Anims.EnsureDict(anim.dict) then isPunching = false return end

    if Targeting.IsLockedOn then Targeting.FaceTarget(playerPed) end
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, anim.dict, anim.name,
        anim.blendIn, anim.blendOut, anim.duration, 49, 0, false, false, false)

    Citizen.SetTimeout(math.floor(anim.duration * anim.damageFrame), function()
        if Targeting.IsLockedOn and Targeting.CurrentTarget then
            local dist = Targeting.GetTargetDistance(GetEntityCoords(playerPed))
            if dist <= Config.LockOnRange * 1.5 then
                local dmg = Config.PunchDamage.counter
                local fx  = Effects.GetIntensity("counter")
                Effects.ApplyDamage(Targeting.CurrentTarget, dmg)
                Effects.CameraShake(fx.shake)
                Effects.Knockback(Targeting.CurrentTarget, playerPed, fx.knockback)
                Effects.PunchSound(Targeting.CurrentTarget, "counter")
                PlayHitReaction(Targeting.CurrentTarget, "heavy")
                Effects.Stagger(Targeting.CurrentTarget, fx.stagger)
                Effects.ScreenFlash()
                Effects.SlowMotion(500)
                local tc = GetEntityCoords(Targeting.CurrentTarget)
                Effects.ImpactParticle(tc + vector3(0.0, 0.0, 0.6))
            end
        end
    end)

    Citizen.SetTimeout(anim.duration, function() isPunching = false end)
    Notify("~y~Counter!")
end

------------------------------------------------------------------------
-- Dodge / weave
------------------------------------------------------------------------
function PerformDodge()
    isDodging = true

    local mx = GetControlNormal(0, 218) -- left/right
    local my = GetControlNormal(0, 219) -- up/down
    local dodgeAnim
    if     mx < -0.3 then dodgeAnim = Anims.Dodge.left
    elseif mx >  0.3 then dodgeAnim = Anims.Dodge.right
    elseif my >  0.3 then dodgeAnim = Anims.Dodge.back
    else                   dodgeAnim = Anims.Dodge.weave end

    if not Anims.EnsureDict(dodgeAnim.dict) then isDodging = false return end

    SetEntityInvincible(playerPed, true)
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, dodgeAnim.dict, dodgeAnim.name,
        dodgeAnim.blendIn, dodgeAnim.blendOut, dodgeAnim.duration, 49, 0, false, false, false)

    Citizen.SetTimeout(dodgeAnim.duration, function()
        isDodging = false
        SetEntityInvincible(playerPed, false)
    end)
end

------------------------------------------------------------------------
-- Finisher (target < 20 % HP)
------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if isInCombat and Targeting.IsLockedOn and Targeting.CurrentTarget
           and DoesEntityExist(Targeting.CurrentTarget) and not IsEntityDead(Targeting.CurrentTarget)
           and not isPunching and not finisherShown then
            local hp    = GetEntityHealth(Targeting.CurrentTarget)
            local maxHp = GetEntityMaxHealth(Targeting.CurrentTarget)
            if maxHp > 0 and (hp / maxHp) < 0.2 then
                finisherShown = true
                ShowFinisherPrompt()
            end
        end
    end
end)

function ShowFinisherPrompt()
    Citizen.CreateThread(function()
        local start = GetGameTimer()
        while GetGameTimer() - start < 3000 do
            Citizen.Wait(0)
            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 50, 50, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("~r~[E]~w~ FINISH")
            DrawText(0.5, 0.85)

            if IsControlJustPressed(0, Config.FinisherKey) then
                PerformFinisher()
                finisherShown = false
                return
            end
        end
        finisherShown = false
    end)
end

function PerformFinisher()
    if isPunching or not Targeting.IsLockedOn then return end
    isPunching = true

    local anim = Anims.Finishers[math.random(1, #Anims.Finishers)]
    if not Anims.EnsureDict(anim.dict) then isPunching = false return end

    Targeting.FaceTarget(playerPed)
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, anim.dict, anim.name,
        anim.blendIn, anim.blendOut, anim.duration, 49, 0, false, false, false)

    Effects.SlowMotion(1200)

    Citizen.SetTimeout(math.floor(anim.duration * anim.damageFrame), function()
        if Targeting.CurrentTarget and DoesEntityExist(Targeting.CurrentTarget) then
            local dmg = Config.PunchDamage.finishing
            local fx  = Effects.GetIntensity("finishing")
            Effects.ApplyDamage(Targeting.CurrentTarget, dmg)
            Effects.CameraShake(fx.shake)
            Effects.Knockback(Targeting.CurrentTarget, playerPed, fx.knockback)
            Effects.PunchSound(Targeting.CurrentTarget, "finishing")
            PlayHitReaction(Targeting.CurrentTarget, "finishing")
            Effects.Stagger(Targeting.CurrentTarget, fx.stagger)
            Effects.ScreenFlash(200)
            local tc = GetEntityCoords(Targeting.CurrentTarget)
            Effects.ImpactParticle(tc + vector3(0.0, 0.0, 0.6))
        end
    end)

    Citizen.SetTimeout(anim.duration, function() isPunching = false end)
end

------------------------------------------------------------------------
-- HUD: combat state + target health bar
------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not isInCombat or not isSystemEnabled then goto skip end

        -- State label (bottom-left)
        local label = "COMBAT"
        if     isBlocking then label = "BLOCKING"
        elseif isDodging  then label = "DODGING"
        elseif isPunching then label = "COMBO x" .. tostring(comboIndex) end

        SetTextFont(4)
        SetTextScale(0.3, 0.3)
        SetTextColour(255, 255, 255, 200)
        SetTextCentre(false)
        SetTextEntry("STRING")
        AddTextComponentString("~b~GTA IV ~w~| " .. label)
        DrawText(0.01, 0.95)

        -- Target health bar (top-center)
        if Targeting.IsLockedOn and Targeting.CurrentTarget
           and DoesEntityExist(Targeting.CurrentTarget) then
            local hp    = GetEntityHealth(Targeting.CurrentTarget)
            local maxHp = GetEntityMaxHealth(Targeting.CurrentTarget)
            local pct   = math.max(0.0, (hp - 100) / math.max(1, maxHp - 100))

            DrawRect(0.5, 0.07, 0.12, 0.012, 0, 0, 0, 150)
            local bw = 0.118 * pct
            local bx = 0.441 + bw / 2
            local r, g = 255, 0
            if pct > 0.5 then r = math.floor(255 * (1 - pct) * 2); g = 255
            else              r = 255; g = math.floor(255 * pct * 2) end
            DrawRect(bx, 0.07, bw, 0.008, r, g, 0, 200)
        end

        ::skip::
    end
end)

------------------------------------------------------------------------
-- Helper
------------------------------------------------------------------------
function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
