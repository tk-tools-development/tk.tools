-- ============================================================
--  COMBAT SYSTEM
--  Handles punch combos, damage, hit detection, and the
--  GTA IV-style heavy melee feel.
-- ============================================================

Combat = {}

-- ---- state --------------------------------------------------
Combat.InCombat       = false
Combat.ComboIndex     = 0
Combat.ComboName      = "Standard"
Combat.LastPunchTime  = 0
Combat.IsPunching     = false
Combat.PunchLocked    = false
Combat.CurrentAnim    = nil
Combat.Stamina        = 100.0
Combat.LastCombatTime = 0
Combat.IsCounterReady = false
Combat.CounterWindow  = 0

-- ---- enter / exit combat mode --------------------------------
function Combat.EnterCombat()
    if Combat.InCombat then return end
    Combat.InCombat      = true
    Combat.ComboIndex    = 0
    Combat.LastCombatTime = Utils.GetTimestamp()

    local ped = PlayerPedId()
    SetPedCanRagdoll(ped, false)

    if Config.EnableAutoFaceTarget then
        local target = Utils.GetClosestPlayer(Config.LockOnRange)
        if target then Utils.FaceEntity(ped, target) end
    end

    local stanceAnim = Anims.Pick(Anims.FightStance)
    if stanceAnim then
        Utils.PlayAnim(ped, stanceAnim.dict, stanceAnim.clip, 4.0, 4.0, -1, 49, 0.0)
    end

    if Config.Debug then print("[TK-FIGHTING] Entered combat mode") end
end

function Combat.ExitCombat()
    if not Combat.InCombat then return end
    Combat.InCombat   = false
    Combat.ComboIndex = 0
    Combat.IsPunching = false
    Combat.PunchLocked = false
    Combat.IsCounterReady = false

    local ped = PlayerPedId()
    ClearPedTasks(ped)
    SetPedCanRagdoll(ped, true)

    if Config.Debug then print("[TK-FIGHTING] Exited combat mode") end
end

-- ---- pick the next attack in the combo chain -----------------
function Combat.GetNextAttack()
    local combo = Anims.Combos[Combat.ComboName]
    if not combo then combo = Anims.Combos.Standard end

    Combat.ComboIndex = Combat.ComboIndex + 1
    if Combat.ComboIndex > #combo then
        Combat.ComboIndex = 1
    end

    local attackType = combo[Combat.ComboIndex]
    local attackAnims = Anims.Attacks[attackType]
    if not attackAnims then
        attackAnims = Anims.Attacks.Jab
        attackType  = "Jab"
    end

    local anim = Anims.Pick(attackAnims)
    return anim, attackType, Combat.ComboIndex == #combo
end

-- ---- throw a light punch -------------------------------------
function Combat.LightPunch()
    if Combat.PunchLocked then return end
    if Combat.IsPunching then return end

    local now = Utils.GetTimestamp()
    if now - Combat.LastPunchTime < Config.CombatCooldown then return end

    if Config.EnableStamina and Combat.Stamina < Config.StaminaDrain then
        return
    end

    Combat.EnterCombat()
    Combat.IsPunching  = true
    Combat.PunchLocked = true
    Combat.LastPunchTime  = now
    Combat.LastCombatTime = now

    if now - Combat.LastPunchTime > Config.ComboWindow and Combat.ComboIndex > 0 then
        Combat.ComboIndex = 0
    end

    local anim, attackType, isFinisher = Combat.GetNextAttack()
    if not anim then
        Combat.IsPunching  = false
        Combat.PunchLocked = false
        return
    end

    local ped = PlayerPedId()

    if Config.EnableAutoFaceTarget then
        local target = Utils.GetClosestPlayer(Config.LockOnRange)
        if target then Utils.FaceEntity(ped, target) end
    end

    local speed = Config.AnimSpeed[attackType] or 1.0
    Combat.CurrentAnim = anim

    Utils.PlayAnim(ped, anim.dict, anim.clip, 2.0, 2.0, anim.duration, 16, speed)

    if Config.EnableStamina then
        Combat.Stamina = Utils.Clamp(Combat.Stamina - Config.StaminaDrain, 0, 100)
    end

    local damageMultiplier = 1.0
    if isFinisher and Config.EnableCombos then
        damageMultiplier = Config.ComboFinisherMult
    end
    if Combat.IsCounterReady and Config.EnableCounterPunch then
        damageMultiplier = damageMultiplier * Config.CounterDamageBonus
        Combat.IsCounterReady = false
    end

    SetTimeout(math.floor(anim.duration * 0.35), function()
        Combat.CheckHit(attackType, damageMultiplier, isFinisher)
    end)

    SetTimeout(anim.duration, function()
        Combat.IsPunching  = false
        Combat.PunchLocked = false
        Combat.CurrentAnim = nil
    end)

    if Config.Debug then
        print(("[TK-FIGHTING] Punch: %s [combo %d] finisher=%s"):format(
            attackType, Combat.ComboIndex, tostring(isFinisher)))
    end
end

-- ---- throw a heavy punch ------------------------------------
function Combat.HeavyPunch()
    if Combat.PunchLocked then return end
    if Combat.IsPunching then return end

    local now = Utils.GetTimestamp()
    if now - Combat.LastPunchTime < Config.CombatCooldown then return end

    if Config.EnableStamina and Combat.Stamina < Config.StaminaDrain * 1.5 then
        return
    end

    Combat.EnterCombat()
    Combat.IsPunching  = true
    Combat.PunchLocked = true
    Combat.LastPunchTime  = now
    Combat.LastCombatTime = now

    local heavyAnims = Anims.Attacks.HeavySwing
    local anim = Anims.Pick(heavyAnims)
    if not anim then
        anim = Anims.Pick(Anims.Attacks.Hook)
    end
    if not anim then
        Combat.IsPunching  = false
        Combat.PunchLocked = false
        return
    end

    local ped = PlayerPedId()

    if Config.EnableAutoFaceTarget then
        local target = Utils.GetClosestPlayer(Config.LockOnRange)
        if target then Utils.FaceEntity(ped, target) end
    end

    local speed = Config.AnimSpeed.HeavySwing or 0.75
    Combat.CurrentAnim = anim

    Utils.PlayAnim(ped, anim.dict, anim.clip, 3.0, 3.0, anim.duration, 16, speed)

    if Config.EnableStamina then
        Combat.Stamina = Utils.Clamp(Combat.Stamina - Config.StaminaDrain * 1.5, 0, 100)
    end

    local damageMultiplier = Config.HeavyPunchMultiplier
    if Combat.IsCounterReady and Config.EnableCounterPunch then
        damageMultiplier = damageMultiplier * Config.CounterDamageBonus
        Combat.IsCounterReady = false
    end

    SetTimeout(math.floor(anim.duration * 0.4), function()
        Combat.CheckHit("HeavySwing", damageMultiplier, false)
    end)

    SetTimeout(anim.duration, function()
        Combat.IsPunching  = false
        Combat.PunchLocked = false
        Combat.CurrentAnim = nil
    end)
end

-- ---- hit detection & damage ----------------------------------
function Combat.CheckHit(attackType, damageMultiplier, isFinisher)
    local ped = PlayerPedId()
    local myCoords = GetEntityCoords(ped)

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            if DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                local dist = #(myCoords - targetCoords)

                if dist <= Config.CombatRange and Utils.IsInFront(ped, targetPed, 90.0) then
                    local damage = Config.BasePunchDamage * (damageMultiplier or 1.0)

                    local isHeadshot = false
                    local headBone = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0) -- SKEL_Head
                    local fistBone = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.0) -- SKEL_R_Hand
                    if #(fistBone - headBone) < 0.5 then
                        isHeadshot = true
                        damage = damage * Config.HeadshotMultiplier
                    end

                    local reactionType = "StaggerLight"
                    if attackType == "Hook" or attackType == "Cross" then
                        reactionType = "StaggerHeavy"
                    elseif attackType == "Uppercut" or attackType == "Finisher" then
                        reactionType = "StaggerHeavy"
                    elseif attackType == "BodyShot" then
                        reactionType = "GutReaction"
                    elseif attackType == "HeavySwing" then
                        reactionType = "StaggerHeavy"
                    end

                    if isHeadshot then
                        reactionType = "HeadSnap"
                    end

                    local shouldKnockdown = false
                    if Config.EnableKnockdowns then
                        local chance = isFinisher and Config.KnockdownComboChance or Config.KnockdownChance
                        if attackType == "HeavySwing" or attackType == "Finisher" or attackType == "Uppercut" then
                            chance = chance * 1.5
                        end
                        if math.random() < chance then
                            shouldKnockdown = true
                            reactionType = "Knockdown"
                        end
                        local targetHealth = GetEntityHealth(targetPed) - 100
                        if targetHealth <= Config.KnockoutThreshold and
                           (attackType == "HeavySwing" or attackType == "Finisher" or attackType == "Uppercut") then
                            shouldKnockdown = true
                            reactionType = "Knockdown"
                        end
                    end

                    TriggerServerEvent("tk-fighting:punchLanded", GetPlayerServerId(playerId), {
                        damage        = math.floor(damage),
                        reaction      = reactionType,
                        attackType    = attackType,
                        isFinisher    = isFinisher,
                        isHeadshot    = isHeadshot,
                        knockdown     = shouldKnockdown,
                        attackerCoords = { x = myCoords.x, y = myCoords.y, z = myCoords.z },
                    })

                    if isHeadshot or attackType == "HeavySwing" or attackType == "Uppercut" then
                        Utils.PlaySound(Config.Sounds.PunchHeavy)
                        Utils.ShakeCamera(Config.HeavyShakeIntensity, 300)
                    else
                        Utils.PlaySound(Config.Sounds.PunchLight)
                        Utils.ShakeCamera(Config.ShakeIntensity, 150)
                    end

                    if shouldKnockdown then
                        Utils.SlowMotion(Config.SlowMotionScale, Config.SlowMotionDuration)
                    end

                    if Config.EnableHitMarker then
                        Utils.FlashScreen(255, 50, 50, 100, 100)
                    end

                    if Config.Debug then
                        print(("[TK-FIGHTING] HIT! type=%s dmg=%d headshot=%s knockdown=%s"):format(
                            attackType, math.floor(damage), tostring(isHeadshot), tostring(shouldKnockdown)))
                    end
                end
            end
        end
    end
end

-- ---- stamina regen tick -------------------------------------
function Combat.TickStamina(dt)
    if not Config.EnableStamina then return end
    if not Combat.IsPunching and not Dodge.IsDodging then
        Combat.Stamina = Utils.Clamp(Combat.Stamina + Config.StaminaRegenRate * dt, 0, 100)
    end
end

-- ---- combo timeout check ------------------------------------
function Combat.TickCombo()
    if Combat.ComboIndex > 0 then
        local now = Utils.GetTimestamp()
        if now - Combat.LastPunchTime > Config.ComboWindow then
            Combat.ComboIndex = 0
        end
    end
end

-- ---- auto-exit combat when idle ------------------------------
function Combat.TickExitCombat()
    if Combat.InCombat and not Combat.IsPunching then
        local now = Utils.GetTimestamp()
        if now - Combat.LastCombatTime > Config.ExitCombatDelay then
            Combat.ExitCombat()
        end
    end
end

-- ---- pick a random combo set ---------------------------------
function Combat.SetComboStyle(name)
    if Anims.Combos[name] then
        Combat.ComboName = name
    end
end

function Combat.RandomizeCombo()
    local names = {}
    for k in pairs(Anims.Combos) do names[#names+1] = k end
    Combat.ComboName = names[math.random(1, #names)]
end
