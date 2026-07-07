-- ============================================================
--  DODGE / WEAVE / BLOCK SYSTEM
--  GTA IV-style evasive movement: slip punches, bob & weave,
--  backstep, and raised-guard blocking.
-- ============================================================

Dodge = {}

-- ---- state --------------------------------------------------
Dodge.IsDodging      = false
Dodge.IsBlocking     = false
Dodge.DodgeLocked    = false
Dodge.BlockAnim      = nil
Dodge.LastDodgeTime  = 0
Dodge.DodgeCooldown  = 600   -- ms between dodges

-- ============================================================
--  DODGING  (Shift + A/D/S while in combat)
-- ============================================================

function Dodge.DodgeLeft()
    Dodge._DoDodge("DuckLeft", "SlipLeft")
end

function Dodge.DodgeRight()
    Dodge._DoDodge("DuckRight", "SlipRight")
end

function Dodge.DodgeBack()
    Dodge._DoDodge("WeaveBack", "WeaveBack")
end

function Dodge._DoDodge(primaryKey, fallbackKey)
    if not Config.EnableWeaving then return end
    if Dodge.IsDodging or Dodge.DodgeLocked then return end
    if Reactions.IsKnockedDown or Reactions.IsKnockedOut then return end
    if Combat.IsPunching then return end

    local now = Utils.GetTimestamp()
    if now - Dodge.LastDodgeTime < Dodge.DodgeCooldown then return end

    if Config.EnableStamina and Combat.Stamina < Config.DodgeStaminaCost then
        return
    end

    Combat.EnterCombat()

    Dodge.IsDodging   = true
    Dodge.DodgeLocked = true
    Dodge.LastDodgeTime = now
    Combat.LastCombatTime = now

    local ped = PlayerPedId()

    if Config.EnableStamina then
        Combat.Stamina = Utils.Clamp(Combat.Stamina - Config.DodgeStaminaCost, 0, 100)
    end

    local dodgeAnims = Anims.Dodges[primaryKey] or Anims.Dodges[fallbackKey]
    local anim = Anims.Pick(dodgeAnims)

    if not anim then
        Dodge.IsDodging   = false
        Dodge.DodgeLocked = false
        return
    end

    local speed = Config.AnimSpeed.Dodge or 1.2

    ClearPedTasks(ped)
    Utils.PlayAnim(ped, anim.dict, anim.clip, 1.5, 2.0, anim.duration, 16, speed)

    local heading = GetEntityHeading(ped)
    local moveForce = 3.0
    local fx, fy = 0.0, 0.0

    if primaryKey == "DuckLeft" or primaryKey == "SlipLeft" then
        local rad = math.rad(heading + 90)
        fx = -math.sin(rad) * moveForce
        fy =  math.cos(rad) * moveForce
    elseif primaryKey == "DuckRight" or primaryKey == "SlipRight" then
        local rad = math.rad(heading - 90)
        fx = -math.sin(rad) * moveForce
        fy =  math.cos(rad) * moveForce
    elseif primaryKey == "WeaveBack" then
        local rad = math.rad(heading + 180)
        fx = -math.sin(rad) * moveForce
        fy =  math.cos(rad) * moveForce
    end

    Utils.ApplyForceToEntity(ped, fx, fy, 0.0)

    if Config.EnableCounterPunch then
        Combat.IsCounterReady = true
        Combat.CounterWindow  = now + 800
    end

    Utils.PlaySound(Config.Sounds.Whoosh)

    SetTimeout(anim.duration, function()
        Dodge.IsDodging   = false
        Dodge.DodgeLocked = false
    end)

    SetTimeout(800, function()
        if Combat.IsCounterReady and Utils.GetTimestamp() >= Combat.CounterWindow then
            Combat.IsCounterReady = false
        end
    end)

    if Config.Debug then
        print(("[TK-FIGHTING] Dodge: %s"):format(primaryKey))
    end
end

-- ============================================================
--  BLOCKING  (Hold RMB / LT)
-- ============================================================

function Dodge.StartBlocking()
    if not Config.EnableBlocking then return end
    if Dodge.IsBlocking then return end
    if Reactions.IsKnockedDown or Reactions.IsKnockedOut then return end
    if Dodge.IsDodging then return end

    Combat.EnterCombat()

    Dodge.IsBlocking = true
    Combat.LastCombatTime = Utils.GetTimestamp()

    local ped = PlayerPedId()

    local enterAnim = Anims.Pick(Anims.Block.Enter)
    if enterAnim then
        Dodge.BlockAnim = enterAnim
        Utils.PlayAnim(ped, enterAnim.dict, enterAnim.clip, 2.0, 2.0, -1, 49, Config.AnimSpeed.Block or 1.0)
    end

    if Config.Debug then
        print("[TK-FIGHTING] Blocking START")
    end
end

function Dodge.StopBlocking()
    if not Dodge.IsBlocking then return end

    Dodge.IsBlocking = false

    local ped = PlayerPedId()

    if Dodge.BlockAnim then
        Utils.StopAnim(ped, Dodge.BlockAnim.dict, Dodge.BlockAnim.clip, 4.0)
        Dodge.BlockAnim = nil
    end

    ClearPedTasks(ped)

    if Combat.InCombat then
        local stanceAnim = Anims.Pick(Anims.FightStance)
        if stanceAnim then
            Utils.PlayAnim(ped, stanceAnim.dict, stanceAnim.clip, 4.0, 4.0, -1, 49, 0.0)
        end
    end

    if Config.Debug then
        print("[TK-FIGHTING] Blocking STOP")
    end
end

function Dodge.TickBlocking()
    if not Dodge.IsBlocking then return end
    Combat.LastCombatTime = Utils.GetTimestamp()
end
