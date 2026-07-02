Config = {}

-- Toggle the entire system on/off with a key
Config.ToggleKey = 344 -- F11

-- Lock-On Targeting
Config.LockOnEnabled = true
Config.LockOnRange = 4.0       -- max distance to land a hit (meters)
Config.LockOnSearchRange = 10.0 -- search radius for finding targets

-- Combat Timing (ms) - slower values = heavier GTA IV feel
Config.PunchCooldown = 600      -- minimum time between punches
Config.ComboCooldown = 1500     -- idle time before combo chain resets
Config.DodgeCooldown = 800      -- minimum time between dodges
Config.CounterWindow = 300      -- window after a blocked hit to press attack for a counter

-- Damage per hit type
Config.PunchDamage = {
    light    = 8,
    heavy    = 18,
    counter  = 25,
    finishing = 35,
}

-- Camera / Visual Effects
Config.CameraShakeOnHit = true
Config.CameraShakeIntensity = 0.15
Config.SlowMotionOnFinisher = true
Config.SlowMotionDuration = 800 -- ms

-- Movement
Config.FightingStanceClipset = "move_m@brave"
Config.MovementSlowdown = 0.7   -- speed multiplier while in combat stance

-- Controls (FiveM control IDs)
Config.DodgeKey = 36       -- Left Ctrl
Config.HeavyAttackKey = 21 -- Left Shift (hold + attack for heavy punch)
Config.FinisherKey = 38    -- E

-- Target Reticle
Config.ShowTargetReticle = true
Config.ReticleColor = { r = 255, g = 50, b = 50, a = 180 }
