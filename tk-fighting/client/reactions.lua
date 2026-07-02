-- ============================================================
--  HIT REACTIONS
--  Handles receiving damage: staggers, knockdowns, knockouts,
--  and the GTA IV "getting rocked" feel.
-- ============================================================

Reactions = {}

-- ---- state --------------------------------------------------
Reactions.IsReacting    = false
Reactions.IsKnockedDown = false
Reactions.IsKnockedOut  = false
Reactions.CurrentAnim   = nil
Reactions.RecoveryTime  = 0

-- ---- apply a hit reaction ------------------------------------
function Reactions.TakeHit(data)
    local ped = PlayerPedId()

    if Reactions.IsKnockedOut then return end

    if Dodge.IsBlocking and Config.EnableBlocking then
        Reactions.BlockHit(data)
        return
    end

    if Dodge.IsDodging then return end

    Reactions.IsReacting = true
    Combat.LastCombatTime = Utils.GetTimestamp()

    local reactionType = data.reaction or "StaggerLight"
    local damage       = data.damage or Config.BasePunchDamage
    local knockdown    = data.knockdown or false
    local isHeadshot   = data.isHeadshot or false
    local attackType   = data.attackType or "Jab"

    ApplyDamageToPed(ped, damage, false)

    if knockdown and Config.EnableKnockdowns then
        Reactions.Knockdown(data)
        return
    end

    local reactionAnims = Anims.Reactions[reactionType]
    if not reactionAnims then
        reactionAnims = Anims.Reactions.StaggerLight
    end

    local anim = Anims.Pick(reactionAnims)
    if not anim then
        Reactions.IsReacting = false
        return
    end

    Reactions.CurrentAnim = anim
    local speed = Config.AnimSpeed[reactionType] or 1.0

    ClearPedTasks(ped)
    Utils.PlayAnim(ped, anim.dict, anim.clip, 2.0, 4.0, anim.duration, 16, speed)

    if data.attackerCoords then
        local attackerPos = vector3(data.attackerCoords.x, data.attackerCoords.y, data.attackerCoords.z)
        local myCoords = GetEntityCoords(ped)
        local dir = myCoords - attackerPos
        if #dir > 0 then
            dir = dir / #dir
            local force = 1.5
            if reactionType == "StaggerHeavy" or reactionType == "HeadSnap" then
                force = 3.0
            end
            Utils.ApplyForceToEntity(ped, dir.x * force, dir.y * force, 0.5)
        end
    end

    if isHeadshot or reactionType == "StaggerHeavy" then
        Utils.ShakeCamera(Config.HeavyShakeIntensity, 400)
    else
        Utils.ShakeCamera(Config.ShakeIntensity, 200)
    end

    Utils.FlashScreen(200, 30, 30, 150, 200)

    SetTimeout(anim.duration, function()
        Reactions.IsReacting = false
        Reactions.CurrentAnim = nil
    end)

    if Config.Debug then
        print(("[TK-FIGHTING] Got hit: %s dmg=%d reaction=%s"):format(
            attackType, damage, reactionType))
    end
end

-- ---- knockdown -----------------------------------------------
function Reactions.Knockdown(data)
    local ped = PlayerPedId()

    Reactions.IsKnockedDown = true
    Reactions.IsReacting    = true

    ClearPedTasks(ped)
    SetPedToRagdoll(ped, Config.KnockdownDuration, Config.KnockdownDuration, 0, false, false, false)

    if data.attackerCoords then
        local attackerPos = vector3(data.attackerCoords.x, data.attackerCoords.y, data.attackerCoords.z)
        local myCoords = GetEntityCoords(ped)
        local dir = myCoords - attackerPos
        if #dir > 0 then
            dir = dir / #dir
            Utils.ApplyForceToEntity(ped, dir.x * 6.0, dir.y * 6.0, 3.0)
        end
    end

    Utils.ShakeCamera(Config.HeavyShakeIntensity * 1.5, 600)
    Utils.FlashScreen(255, 0, 0, 200, 400)
    Utils.PlaySound(Config.Sounds.KnockdownHit)

    local health = GetEntityHealth(ped) - 100
    if health <= Config.KnockoutThreshold then
        Reactions.Knockout(data)
        return
    end

    SetTimeout(Config.KnockdownDuration, function()
        Reactions.GetUp()
    end)

    if Config.Debug then
        print("[TK-FIGHTING] KNOCKED DOWN!")
    end
end

-- ---- knockout (extended down time) ---------------------------
function Reactions.Knockout(data)
    local ped = PlayerPedId()

    Reactions.IsKnockedOut  = true
    Reactions.IsKnockedDown = true
    Reactions.IsReacting    = true

    ClearPedTasks(ped)
    SetPedToRagdoll(ped, Config.KnockoutDuration, Config.KnockoutDuration, 0, false, false, false)

    Utils.SlowMotion(Config.SlowMotionScale, Config.SlowMotionDuration)
    Utils.ShakeCamera(Config.HeavyShakeIntensity * 2.0, 800)

    AnimpostfxPlay("DrugsMichaelAliensFightIn", 0, false)
    SetTimeout(Config.KnockoutDuration, function()
        AnimpostfxStop("DrugsMichaelAliensFightIn")
    end)

    SetTimeout(Config.KnockoutDuration, function()
        Reactions.GetUp()
        Reactions.IsKnockedOut = false
    end)

    if Config.Debug then
        print("[TK-FIGHTING] KNOCKED OUT!")
    end
end

-- ---- get back up ---------------------------------------------
function Reactions.GetUp()
    local ped = PlayerPedId()

    ClearPedTasksImmediately(ped)
    SetPedCanRagdoll(ped, false)

    local getUpAnim = Anims.Pick(Anims.Reactions.GetUp)
    if getUpAnim then
        Utils.PlayAnim(ped, getUpAnim.dict, getUpAnim.clip, 4.0, 4.0, getUpAnim.duration, 16, 1.0)
        SetTimeout(getUpAnim.duration, function()
            Reactions.IsKnockedDown = false
            Reactions.IsReacting    = false
            Reactions.CurrentAnim   = nil
            SetPedCanRagdoll(ped, true)
        end)
    else
        Reactions.IsKnockedDown = false
        Reactions.IsReacting    = false
        SetPedCanRagdoll(ped, true)
    end
end

-- ---- block-hit reaction (reduced flinch) ---------------------
function Reactions.BlockHit(data)
    local ped = PlayerPedId()

    local damage = math.floor((data.damage or Config.BasePunchDamage) * (1.0 - Config.BlockDamageReduction))
    ApplyDamageToPed(ped, damage, false)

    if Config.EnableStamina then
        Combat.Stamina = Utils.Clamp(Combat.Stamina - Config.BlockStaminaDrain, 0, 100)
    end

    local blockAnims = Anims.Reactions.BlockHit
    local anim = Anims.Pick(blockAnims)
    if anim then
        Utils.PlayAnim(ped, anim.dict, anim.clip, 1.0, 2.0, anim.duration, 48, 1.2)
    end

    Utils.PlaySound(Config.Sounds.Block)
    Utils.ShakeCamera(Config.ShakeIntensity * 0.5, 100)

    if Combat.Stamina <= 0 then
        Dodge.StopBlocking()
        Reactions.TakeHit({
            damage       = data.damage,
            reaction     = "StaggerHeavy",
            attackType   = data.attackType,
            knockdown    = false,
            isHeadshot   = false,
            attackerCoords = data.attackerCoords,
        })
    end

    if Config.Debug then
        print(("[TK-FIGHTING] Blocked! reduced dmg=%d stamina=%.0f"):format(damage, Combat.Stamina))
    end
end

-- ---- net event: receive a punch from another player ----------
RegisterNetEvent("tk-fighting:receiveHit")
AddEventHandler("tk-fighting:receiveHit", function(data)
    Reactions.TakeHit(data)
end)
