-- ============================================================
--  ANIMATION DEFINITIONS
--  All animation dictionaries and clips used by the combat system.
--  Organized by category for easy tweaking.
-- ============================================================

Anims = {}

-- ============================================================
--  ATTACK ANIMATIONS  (GTA IV-style heavy, deliberate punches)
-- ============================================================
Anims.Attacks = {
    -- ----------------------------------------
    --  JAB  (quick left straight)
    -- ----------------------------------------
    Jab = {
        { dict = "melee@unarmed@streamed_core",      clip = "plyr_walking_punch",       duration = 600  },
        { dict = "melee@unarmed@streamed_core",      clip = "small_punch_a",             duration = 550  },
    },
    -- ----------------------------------------
    --  CROSS  (hard right straight)
    -- ----------------------------------------
    Cross = {
        { dict = "melee@unarmed@streamed_core",      clip = "small_punch_b",             duration = 700  },
        { dict = "melee@unarmed@streamed_core",      clip = "plyr_running_punch",        duration = 750  },
    },
    -- ----------------------------------------
    --  HOOK  (wide swinging punch)
    -- ----------------------------------------
    Hook = {
        { dict = "melee@unarmed@streamed_core",      clip = "heavy_punch_a",             duration = 800  },
        { dict = "melee@unarmed@streamed_core",      clip = "heavy_punch_b",             duration = 850  },
    },
    -- ----------------------------------------
    --  UPPERCUT  (rising punch from below)
    -- ----------------------------------------
    Uppercut = {
        { dict = "melee@unarmed@streamed_core",      clip = "heavy_finishing_punch",     duration = 900  },
        { dict = "melee@unarmed@streamed_core",      clip = "plyr_takedown_front_finish", duration = 950 },
    },
    -- ----------------------------------------
    --  BODY SHOT  (punch to the gut)
    -- ----------------------------------------
    BodyShot = {
        { dict = "melee@unarmed@streamed_core",      clip = "plyr_walking_punch",       duration = 650  },
        { dict = "melee@unarmed@streamed_core",      clip = "small_punch_a",             duration = 600  },
    },
    -- ----------------------------------------
    --  HEAVY SWING  (wild haymaker)
    -- ----------------------------------------
    HeavySwing = {
        { dict = "melee@unarmed@streamed_core",      clip = "heavy_punch_a",             duration = 1000 },
        { dict = "melee@unarmed@streamed_core",      clip = "heavy_punch_b",             duration = 1050 },
    },
    -- ----------------------------------------
    --  FINISHER  (devastating combo ender)
    -- ----------------------------------------
    Finisher = {
        { dict = "melee@unarmed@streamed_core",      clip = "heavy_finishing_punch",     duration = 1100 },
        { dict = "melee@unarmed@streamed_core",      clip = "plyr_takedown_front_finish", duration = 1200 },
    },
}

-- ============================================================
--  COMBO SEQUENCES
--  Each combo is an ordered list of attack types.
--  The system cycles through these; the last one uses
--  the Finisher multiplier from config.
-- ============================================================
Anims.Combos = {
    -- 4-hit GTA IV style combo: jab - cross - hook - uppercut
    Standard = { "Jab", "Cross", "Hook", "Uppercut" },

    -- 3-hit body combo
    BodyCombo = { "Jab", "BodyShot", "Hook" },

    -- 5-hit brawler combo
    Brawler = { "Jab", "Cross", "Jab", "Hook", "HeavySwing" },

    -- 2-hit heavy
    PowerShot = { "HeavySwing", "Finisher" },
}

-- ============================================================
--  HIT-REACTION ANIMATIONS
-- ============================================================
Anims.Reactions = {
    -- Light stagger (took a jab)
    StaggerLight = {
        { dict = "random@drunk_driver",           clip = "yourdriving_takekeys",       duration = 800  },
        { dict = "missminuteman_1ig_2",            clip = "tasered_2",                  duration = 750  },
        { dict = "random@mugging3",                clip = "handsup_enterit",            duration = 700  },
    },
    -- Heavy stagger (took a hook/cross)
    StaggerHeavy = {
        { dict = "random@drunk_driver",           clip = "yourdriving_takekeys",       duration = 1100 },
        { dict = "move_m@drunk@verydrunk",         clip = "idle",                       duration = 1200 },
    },
    -- Head snap back (headshot reaction)
    HeadSnap = {
        { dict = "random@drunk_driver",           clip = "yourdriving_takekeys",       duration = 600  },
        { dict = "missminuteman_1ig_2",            clip = "tasered_2",                  duration = 650  },
    },
    -- Gut reaction (body shot)
    GutReaction = {
        { dict = "random@mugging3",                clip = "handsup_enterit",            duration = 900  },
        { dict = "move_m@drunk@verydrunk",         clip = "idle",                       duration = 950  },
    },
    -- Knockdown (fall to ground)
    Knockdown = {
        { dict = "random@drunk_driver",           clip = "yourdriving_takekeys",       duration = 2500 },
        { dict = "move_m@drunk@verydrunk",         clip = "idle",                       duration = 2800 },
    },
    -- Getting back up
    GetUp = {
        { dict = "random@drunk_driver",           clip = "yourdriving_takekeys",       duration = 1500 },
        { dict = "move_m@drunk@verydrunk",         clip = "idle",                       duration = 1600 },
    },
    -- Block-hit (small flinch when hit while blocking)
    BlockHit = {
        { dict = "random@drunk_driver",           clip = "yourdriving_takekeys",       duration = 400  },
    },
}

-- ============================================================
--  DODGE / WEAVE ANIMATIONS
-- ============================================================
Anims.Dodges = {
    DuckLeft = {
        { dict = "move_strafe@stealth",            clip = "walk_lft",                   duration = 500  },
    },
    DuckRight = {
        { dict = "move_strafe@stealth",            clip = "walk_rgt",                   duration = 500  },
    },
    WeaveBack = {
        { dict = "move_strafe@stealth",            clip = "walk_bwd",                   duration = 550  },
    },
    SlipLeft = {
        { dict = "move_strafe@stealth",            clip = "run_lft",                    duration = 450  },
    },
    SlipRight = {
        { dict = "move_strafe@stealth",            clip = "run_rgt",                    duration = 450  },
    },
}

-- ============================================================
--  BLOCK / GUARD STANCE
-- ============================================================
Anims.Block = {
    Enter = {
        { dict = "melee@unarmed@streamed_core",    clip = "plyr_block",                 duration = -1   },
    },
    Idle = {
        { dict = "melee@unarmed@streamed_core",    clip = "plyr_block_idle",            duration = -1   },
    },
    Exit = {
        { dict = "melee@unarmed@streamed_core",    clip = "plyr_block",                 duration = 400  },
    },
}

-- ============================================================
--  IDLE FIGHT STANCE  (used while in combat mode but not punching)
-- ============================================================
Anims.FightStance = {
    { dict = "melee@unarmed@streamed_core",        clip = "idle",                       duration = -1   },
}

-- ============================================================
--  TAUNT / INTIMIDATION
-- ============================================================
Anims.Taunts = {
    { dict = "gesture_ambient@world@human@male@standing@casual",  clip = "gesture_come_here_hard",  duration = 2000 },
    { dict = "anim@mp_player_intcelebrationmale@shadow_boxing",   clip = "shadow_boxing",           duration = 3000 },
}

-- ============================================================
--  HELPER: pick a random anim from a category table
-- ============================================================
function Anims.Pick(animTable)
    if not animTable or #animTable == 0 then return nil end
    return animTable[math.random(1, #animTable)]
end

-- ============================================================
--  PRELOAD: request all dicts used by the system
-- ============================================================
function Anims.PreloadAll()
    local dicts = {}
    local function collect(tbl)
        if type(tbl) ~= "table" then return end
        if tbl.dict then
            dicts[tbl.dict] = true
            return
        end
        for _, v in pairs(tbl) do
            collect(v)
        end
    end
    collect(Anims.Attacks)
    collect(Anims.Reactions)
    collect(Anims.Dodges)
    collect(Anims.Block)
    collect(Anims.FightStance)
    collect(Anims.Taunts)

    for dict in pairs(dicts) do
        Utils.LoadAnimDict(dict)
    end
end
