-- ============================================================
--  TK-FIGHTING  |  CLIENT MAIN
--  Entry point: input handling, main loop, HUD, and
--  disabling vanilla melee so our system takes over.
-- ============================================================

local initialized = false

-- ---- one-time init -------------------------------------------
Citizen.CreateThread(function()
    Anims.PreloadAll()
    initialized = true
    if Config.Debug then print("[TK-FIGHTING] Animations preloaded") end
end)

-- ============================================================
--  DISABLE VANILLA MELEE CONTROLS
--  We intercept the default melee so our custom anims play
--  instead of GTA V's default punch system.
-- ============================================================
local vanillaMeleeControls = {
    140,  -- INPUT_MELEE_ATTACK_LIGHT
    141,  -- INPUT_MELEE_ATTACK_HEAVY
    142,  -- INPUT_MELEE_ATTACK_ALTERNATE
    143,  -- INPUT_MELEE_ATTACK_ALTERNATE_2  (some builds)
    263,  -- INPUT_MELEE_BLOCK
    264,  -- INPUT_MELEE_BLOCK2 (some builds)
}

local function DisableVanillaMelee()
    for _, ctrl in ipairs(vanillaMeleeControls) do
        DisableControlAction(0, ctrl, true)
    end
end

-- ============================================================
--  SHOULD WE INTERCEPT?
--  Only override melee when unarmed (fists equipped).
-- ============================================================
local function IsUnarmed()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    -- 0xA2719263 = WEAPON_UNARMED hash
    return weapon == GetHashKey("WEAPON_UNARMED") or weapon == 0xA2719263
end

-- ============================================================
--  INPUT HANDLER  (runs every frame)
-- ============================================================
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not initialized then goto continue end

        local ped = PlayerPedId()
        if IsEntityDead(ped) or IsPedInAnyVehicle(ped) then
            if Combat.InCombat then Combat.ExitCombat() end
            goto continue
        end

        if not IsUnarmed() then
            if Combat.InCombat then Combat.ExitCombat() end
            goto continue
        end

        DisableVanillaMelee()

        -- ---- LIGHT PUNCH (LMB / RT) ----
        if IsDisabledControlJustPressed(0, Config.Keys.LightPunch) then
            if not Reactions.IsReacting and not Reactions.IsKnockedDown then
                Combat.LightPunch()
            end
        end

        -- ---- HEAVY PUNCH (R / special) ----
        if IsDisabledControlJustPressed(0, Config.Keys.HeavyPunch) then
            if not Reactions.IsReacting and not Reactions.IsKnockedDown then
                Combat.HeavyPunch()
            end
        end

        -- ---- BLOCK (RMB / LT - hold) ----
        if IsDisabledControlPressed(0, Config.Keys.Block) then
            if not Combat.IsPunching and not Reactions.IsReacting and not Reactions.IsKnockedDown then
                Dodge.StartBlocking()
            end
        elseif Dodge.IsBlocking then
            Dodge.StopBlocking()
        end

        -- ---- DODGE (Shift + A/D/S) ----
        if IsControlPressed(0, Config.Keys.DodgeModifier) then
            if IsControlJustPressed(0, Config.Keys.DodgeLeft) then
                Dodge.DodgeLeft()
            elseif IsControlJustPressed(0, Config.Keys.DodgeRight) then
                Dodge.DodgeRight()
            elseif IsControlJustPressed(0, Config.Keys.DodgeBack) then
                Dodge.DodgeBack()
            end
        end

        ::continue::
    end
end)

-- ============================================================
--  GAME LOGIC TICK  (lower frequency - 4 ms)
-- ============================================================
Citizen.CreateThread(function()
    while true do
        Wait(4)
        if not initialized then goto skip end

        local dt = 0.004  -- ~4ms in seconds

        Combat.TickStamina(dt)
        Combat.TickCombo()
        Combat.TickExitCombat()
        Dodge.TickBlocking()

        -- counter window expiry
        if Combat.IsCounterReady and Utils.GetTimestamp() >= Combat.CounterWindow then
            Combat.IsCounterReady = false
        end

        ::skip::
    end
end)

-- ============================================================
--  HUD  (stamina bar + combo counter)
-- ============================================================
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not initialized then goto skip_hud end
        if not Combat.InCombat then goto skip_hud end

        -- stamina bar background
        DrawRect(0.5, 0.95, 0.12, 0.018, 0, 0, 0, 160)

        -- stamina bar fill
        local pct = Combat.Stamina / 100.0
        local barWidth = 0.115 * pct
        local barX = 0.5 - (0.115 / 2) + (barWidth / 2)
        local r, g, b = 50, 200, 50
        if pct < 0.3 then
            r, g, b = 220, 50, 50
        elseif pct < 0.6 then
            r, g, b = 220, 180, 50
        end
        DrawRect(barX, 0.95, barWidth, 0.012, r, g, b, 200)

        -- combo indicator
        if Combat.ComboIndex > 0 then
            SetTextFont(4)
            SetTextProportional(true)
            SetTextScale(0.0, 0.4)
            SetTextColour(255, 220, 50, 230)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(("COMBO x%d"):format(Combat.ComboIndex))
            DrawText(0.48, 0.91)
        end

        -- counter-punch indicator
        if Combat.IsCounterReady then
            SetTextFont(4)
            SetTextProportional(true)
            SetTextScale(0.0, 0.35)
            SetTextColour(100, 255, 100, 230)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("COUNTER!")
            DrawText(0.485, 0.885)
        end

        -- block indicator
        if Dodge.IsBlocking then
            SetTextFont(4)
            SetTextProportional(true)
            SetTextScale(0.0, 0.35)
            SetTextColour(100, 180, 255, 230)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("BLOCKING")
            DrawText(0.48, 0.87)
        end

        ::skip_hud::
    end
end)

-- ============================================================
--  DEBUG DISPLAY
-- ============================================================
if Config.Debug then
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if Combat.InCombat then
                Utils.DrawDebugText(
                    ("Combat: combo=%d/%s punching=%s blocking=%s dodging=%s stamina=%.0f counter=%s"):format(
                        Combat.ComboIndex,
                        Combat.ComboName,
                        tostring(Combat.IsPunching),
                        tostring(Dodge.IsBlocking),
                        tostring(Dodge.IsDodging),
                        Combat.Stamina,
                        tostring(Combat.IsCounterReady)
                    )
                )
            end
        end
    end)
end

-- ============================================================
--  COMMANDS
-- ============================================================

RegisterCommand("fightcombo", function(_, args)
    local style = args[1] or "Standard"
    if Anims.Combos[style] then
        Combat.SetComboStyle(style)
        TriggerEvent("chat:addMessage", {
            color = {255, 180, 50},
            args  = {"TK-FIGHTING", "Combo style set to: " .. style}
        })
    else
        local available = {}
        for k in pairs(Anims.Combos) do available[#available+1] = k end
        TriggerEvent("chat:addMessage", {
            color = {255, 80, 80},
            args  = {"TK-FIGHTING", "Unknown style. Available: " .. table.concat(available, ", ")}
        })
    end
end, false)

RegisterCommand("fightrandom", function()
    Combat.RandomizeCombo()
    TriggerEvent("chat:addMessage", {
        color = {255, 180, 50},
        args  = {"TK-FIGHTING", "Randomized combo style to: " .. Combat.ComboName}
    })
end, false)

RegisterCommand("fightreset", function()
    Combat.ExitCombat()
    Reactions.IsReacting    = false
    Reactions.IsKnockedDown = false
    Reactions.IsKnockedOut  = false
    Dodge.IsBlocking        = false
    Dodge.IsDodging         = false
    Combat.Stamina          = 100
    ClearPedTasksImmediately(PlayerPedId())
    TriggerEvent("chat:addMessage", {
        color = {100, 255, 100},
        args  = {"TK-FIGHTING", "Fight state reset."}
    })
end, false)

RegisterCommand("fighttaunt", function()
    local ped = PlayerPedId()
    local taunt = Anims.Pick(Anims.Taunts)
    if taunt then
        Utils.PlayAnim(ped, taunt.dict, taunt.clip, 4.0, 4.0, taunt.duration, 48, 1.0)
    end
end, false)

-- ============================================================
--  CLEANUP ON RESOURCE STOP
-- ============================================================
AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Combat.ExitCombat()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    SetPedCanRagdoll(ped, true)
    SetTimeScale(1.0)
    StopGameplayCamShaking(true)
    StopScreenEffect("FocusOut")
    AnimpostfxStop("DrugsMichaelAliensFightIn")
end)
