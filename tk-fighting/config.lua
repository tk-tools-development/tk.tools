Config = {}

-- ============================================================
--  GENERAL
-- ============================================================
Config.Debug                = false
Config.CombatRange          = 2.0       -- max distance (meters) a punch can connect
Config.LockOnRange          = 3.5       -- range to auto-face nearest target
Config.ComboWindow          = 800       -- ms to chain the next punch before combo resets
Config.CombatCooldown       = 350       -- ms minimum between punches
Config.ExitCombatDelay      = 4000      -- ms of no combat before leaving fight stance
Config.StaminaDrain         = 8.0       -- stamina lost per punch thrown
Config.StaminaRegenRate     = 3.0       -- stamina regained per second when idle
Config.BlockStaminaDrain    = 4.0       -- stamina lost per blocked hit
Config.DodgeStaminaCost     = 12.0      -- stamina cost per dodge

-- ============================================================
--  DAMAGE
-- ============================================================
Config.BasePunchDamage      = 8         -- base damage for a jab
Config.HeavyPunchMultiplier = 1.8       -- multiplier for heavy / finishing hits
Config.ComboFinisherMult    = 2.5       -- multiplier for the last hit in a full combo
Config.BlockDamageReduction = 0.80      -- 80% damage blocked
Config.CounterDamageBonus   = 1.5       -- bonus multiplier when counter-punching after a dodge
Config.HeadshotMultiplier   = 1.3       -- bonus damage for head-level hits

-- ============================================================
--  KNOCKDOWN / KNOCKOUT
-- ============================================================
Config.KnockdownChance      = 0.15     -- base chance per heavy hit
Config.KnockdownComboChance = 0.40     -- chance on combo finisher
Config.KnockoutThreshold    = 20       -- health at which a heavy hit triggers KO
Config.KnockdownDuration    = 2500     -- ms on the ground
Config.KnockoutDuration     = 5000     -- ms fully knocked out
Config.StaggerDuration      = 800      -- ms stagger animation plays

-- ============================================================
--  CAMERA & EFFECTS
-- ============================================================
Config.CameraShakeOnHit     = true
Config.ShakeIntensity       = 0.12     -- 0.0 - 1.0
Config.HeavyShakeIntensity  = 0.25
Config.SlowMotionOnKO       = true
Config.SlowMotionDuration   = 1200     -- ms
Config.SlowMotionScale      = 0.3      -- time scale during slow-mo
Config.FlashScreenOnHit     = true

-- ============================================================
--  KEYBINDS  (FiveM control IDs)
--  Full list: https://docs.fivem.net/docs/game-references/controls/
-- ============================================================
Config.Keys = {
    LightPunch   = 24,   -- INPUT_ATTACK  (LMB / RT)
    HeavyPunch   = 141,  -- INPUT_MELEE_ATTACK_HEAVY (R on KB)
    Block        = 25,   -- INPUT_AIM  (RMB / LT)  -- hold to block
    DodgeLeft    = 34,   -- INPUT_MOVE_LEFT_ONLY (A)
    DodgeRight   = 35,   -- INPUT_MOVE_RIGHT_ONLY (D)
    DodgeBack    = 33,   -- INPUT_MOVE_DOWN_ONLY (S)
    DodgeModifier= 21,   -- INPUT_SPRINT (L-Shift) -- hold + direction = dodge
}

-- ============================================================
--  ANIMATION SPEEDS  (playback rate multipliers)
-- ============================================================
Config.AnimSpeed = {
    Jab          = 1.1,
    Cross        = 1.0,
    Hook         = 0.95,
    Uppercut     = 0.85,
    BodyShot     = 1.0,
    HeavySwing   = 0.75,
    Finisher     = 0.70,
    Dodge        = 1.2,
    Block        = 1.0,
    StaggerLight = 1.0,
    StaggerHeavy = 0.85,
    Knockdown    = 0.80,
}

-- ============================================================
--  TOGGLE FEATURES
-- ============================================================
Config.EnableWeaving        = true    -- allow dodge/weave moves
Config.EnableBlocking       = true    -- allow blocking
Config.EnableCombos         = true    -- allow punch combos
Config.EnableCounterPunch   = true    -- allow counters after dodge
Config.EnableKnockdowns     = true    -- allow knockdowns/KOs
Config.EnableCameraEffects  = true    -- camera shake & slow-mo
Config.EnableStamina        = true    -- stamina system
Config.EnableAutoFaceTarget = true    -- auto-rotate toward nearest enemy
Config.EnableHitMarker      = true    -- flash on screen when hit lands
Config.EnableSounds         = true    -- play impact sounds

-- ============================================================
--  SOUNDS  (vanilla GTA V sound names)
-- ============================================================
Config.Sounds = {
    PunchLight   = { set = "MELEE_FIST_SOUNDSET",   name = "Hit" },
    PunchHeavy   = { set = "MELEE_FIST_SOUNDSET",   name = "HIT_FAST" },
    Block        = { set = "MELEE_FIST_SOUNDSET",   name = "HIT_SLOW" },
    Whoosh       = { set = "MELEE_FIST_SOUNDSET",   name = "YOURDRIVING_TAKEKEYS" },
    KnockdownHit = { set = "MELEE_FIST_SOUNDSET",   name = "Hit" },
}
