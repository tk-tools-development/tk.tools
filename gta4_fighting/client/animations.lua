-- GTA IV Style Animation Definitions
-- All animation dicts / names reference assets that ship with GTA V.

Anims = {}

-- Dictionaries to preload on resource start
Anims.Dicts = {
    "melee@unarmed@streamed_core",
    "melee@unarmed@streamed_core_fps",
    "melee@unarmed@streamed_variations",
    "melee@large_wpn@streamed_core",
    "anim@melee@machete@streamed_core",
    "random@arrests",
    "move_m@brave",
    "combat@aim_variations@1h",
}

------------------------------------------------------------------------
-- Punch combo chain (4-hit: jab -> cross -> hook -> uppercut)
------------------------------------------------------------------------
Anims.PunchCombo = {
    [1] = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_fwd_0",
        blendIn  = 2.0,
        blendOut = -2.0,
        duration = 800,
        damageFrame = 0.3,
        type = "light",
    },
    [2] = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_fwd_1",
        blendIn  = 2.0,
        blendOut = -2.0,
        duration = 900,
        damageFrame = 0.35,
        type = "light",
    },
    [3] = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_fwd_2",
        blendIn  = 2.0,
        blendOut = -2.0,
        duration = 1000,
        damageFrame = 0.4,
        type = "heavy",
    },
    [4] = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_fwd_3",
        blendIn  = 2.0,
        blendOut = -2.0,
        duration = 1200,
        damageFrame = 0.45,
        type = "finishing",
    },
}

------------------------------------------------------------------------
-- Heavy punches (Shift + Attack)
------------------------------------------------------------------------
Anims.HeavyPunch = {
    [1] = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_running_attack",
        blendIn  = 4.0,
        blendOut = -4.0,
        duration = 1400,
        damageFrame = 0.4,
        type = "heavy",
    },
    [2] = {
        dict = "melee@large_wpn@streamed_core",
        name = "plyr_fwd_0",
        blendIn  = 4.0,
        blendOut = -4.0,
        duration = 1300,
        damageFrame = 0.45,
        type = "heavy",
    },
}

------------------------------------------------------------------------
-- Dodge / weave animations (directional)
------------------------------------------------------------------------
Anims.Dodge = {
    left = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_dodge_0",
        blendIn  = 3.0,
        blendOut = -3.0,
        duration = 700,
    },
    right = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_dodge_1",
        blendIn  = 3.0,
        blendOut = -3.0,
        duration = 700,
    },
    back = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_dodge_2",
        blendIn  = 3.0,
        blendOut = -3.0,
        duration = 800,
    },
    weave = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_dodge_3",
        blendIn  = 3.0,
        blendOut = -3.0,
        duration = 600,
    },
}

------------------------------------------------------------------------
-- Hit reactions (played on the target that gets punched)
------------------------------------------------------------------------
Anims.HitReactions = {
    light = {
        [1] = { dict = "melee@unarmed@streamed_core", name = "plyr_hit_0",
                blendIn = 4.0, blendOut = -4.0, duration = 800 },
        [2] = { dict = "melee@unarmed@streamed_core", name = "plyr_hit_1",
                blendIn = 4.0, blendOut = -4.0, duration = 800 },
        [3] = { dict = "melee@unarmed@streamed_core", name = "plyr_hit_2",
                blendIn = 4.0, blendOut = -4.0, duration = 900 },
    },
    heavy = {
        [1] = { dict = "melee@unarmed@streamed_core", name = "plyr_hit_3",
                blendIn = 4.0, blendOut = -4.0, duration = 1100 },
        [2] = { dict = "melee@unarmed@streamed_core", name = "plyr_hit_4",
                blendIn = 4.0, blendOut = -4.0, duration = 1200 },
    },
    finishing = {
        [1] = { dict = "melee@unarmed@streamed_core", name = "plyr_hit_5",
                blendIn = 4.0, blendOut = -4.0, duration = 1500 },
    },
}

------------------------------------------------------------------------
-- Block
------------------------------------------------------------------------
Anims.Block = {
    enter = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_block_0",
        blendIn  = 3.0,
        blendOut = -3.0,
        duration = -1,
    },
    hit = {
        dict = "melee@unarmed@streamed_core",
        name = "plyr_block_1",
        blendIn  = 4.0,
        blendOut = -4.0,
        duration = 600,
    },
}

------------------------------------------------------------------------
-- Counter-attack (timed block -> attack)
------------------------------------------------------------------------
Anims.Counter = {
    dict = "melee@unarmed@streamed_core",
    name = "plyr_finishing_0",
    blendIn  = 2.0,
    blendOut = -2.0,
    duration = 1400,
    damageFrame = 0.35,
    type = "counter",
}

------------------------------------------------------------------------
-- Finishing moves (when target < 20 % health)
------------------------------------------------------------------------
Anims.Finishers = {
    [1] = { dict = "melee@unarmed@streamed_core", name = "plyr_finishing_0",
            blendIn = 2.0, blendOut = -2.0, duration = 2000, damageFrame = 0.5,
            type = "finishing" },
    [2] = { dict = "melee@unarmed@streamed_core", name = "plyr_finishing_1",
            blendIn = 2.0, blendOut = -2.0, duration = 2200, damageFrame = 0.5,
            type = "finishing" },
    [3] = { dict = "melee@unarmed@streamed_core", name = "plyr_finishing_2",
            blendIn = 2.0, blendOut = -2.0, duration = 2400, damageFrame = 0.55,
            type = "finishing" },
}

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

function Anims.LoadAll()
    local loaded = {}
    for _, dict in ipairs(Anims.Dicts) do
        if not loaded[dict] then
            RequestAnimDict(dict)
            local timeout = 500
            while not HasAnimDictLoaded(dict) and timeout > 0 do
                Citizen.Wait(10)
                timeout = timeout - 1
            end
            loaded[dict] = true
        end
    end
end

function Anims.UnloadAll()
    for _, dict in ipairs(Anims.Dicts) do
        RemoveAnimDict(dict)
    end
end

function Anims.EnsureDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local timeout = 500
        while not HasAnimDictLoaded(dict) and timeout > 0 do
            Citizen.Wait(10)
            timeout = timeout - 1
        end
    end
    return HasAnimDictLoaded(dict)
end
