-- ============================================================
--  UTILITY HELPERS
-- ============================================================

Utils = {}

function Utils.LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = 500
    while not HasAnimDictLoaded(dict) and timeout > 0 do
        Wait(10)
        timeout = timeout - 10
    end
    return HasAnimDictLoaded(dict)
end

function Utils.PlayAnim(ped, dict, clip, blendIn, blendOut, duration, flag, rate, lockX, lockY, lockZ)
    if not Utils.LoadAnimDict(dict) then return false end
    TaskPlayAnim(ped, dict, clip,
        blendIn  or 2.0,
        blendOut or 2.0,
        duration or -1,
        flag     or 0,
        rate     or 0.0,
        lockX    or false,
        lockY    or false,
        lockZ    or false
    )
    return true
end

function Utils.StopAnim(ped, dict, clip, blendOut)
    StopAnimTask(ped, dict, clip, blendOut or 2.0)
end

function Utils.IsPlayingAnim(ped, dict, clip)
    return IsEntityPlayingAnim(ped, dict, clip, 3)
end

function Utils.GetClosestPlayer(range)
    local myPed    = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local closest  = nil
    local closeDist = range or Config.CombatRange

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            if DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
                local dist = #(myCoords - GetEntityCoords(targetPed))
                if dist < closeDist then
                    closeDist = dist
                    closest   = targetPed
                end
            end
        end
    end

    return closest, closeDist
end

function Utils.FaceEntity(ped, target)
    if not DoesEntityExist(target) then return end
    local myCoords     = GetEntityCoords(ped)
    local targetCoords = GetEntityCoords(target)
    local dx = targetCoords.x - myCoords.x
    local dy = targetCoords.y - myCoords.y
    local heading = math.deg(math.atan(dx, dy))
    if heading < 0.0 then heading = heading + 360.0 end
    SetEntityHeading(ped, heading)
end

function Utils.ApplyForceToEntity(entity, forceX, forceY, forceZ)
    ApplyForceToEntity(entity, 1,
        forceX, forceY, forceZ,
        0.0, 0.0, 0.0,
        0, false, true, true, false, true
    )
end

function Utils.ShakeCamera(intensity, duration)
    if not Config.EnableCameraEffects or not Config.CameraShakeOnHit then return end
    ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", intensity)
    SetTimeout(duration or 200, function()
        StopGameplayCamShaking(true)
    end)
end

function Utils.FlashScreen(r, g, b, a, duration)
    if not Config.EnableCameraEffects or not Config.FlashScreenOnHit then return end
    StartScreenEffect("FocusOut", 0, false)
    SetTimeout(duration or 150, function()
        StopScreenEffect("FocusOut")
    end)
end

function Utils.SlowMotion(scale, duration)
    if not Config.EnableCameraEffects or not Config.SlowMotionOnKO then return end
    SetTimeScale(scale or Config.SlowMotionScale)
    SetTimeout(duration or Config.SlowMotionDuration, function()
        SetTimeScale(1.0)
    end)
end

function Utils.PlaySound(soundData)
    if not Config.EnableSounds or not soundData then return end
    PlaySoundFrontend(-1, soundData.name, soundData.set, true)
end

function Utils.DrawDebugText(text)
    if not Config.Debug then return end
    SetTextFont(0)
    SetTextProportional(true)
    SetTextScale(0.0, 0.35)
    SetTextColour(255, 255, 255, 230)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.01, 0.01)
end

function Utils.GetTimestamp()
    return GetGameTimer()
end

function Utils.Clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.RandomFloat(min, max)
    return min + math.random() * (max - min)
end

function Utils.IsInFront(ped, target, angle)
    angle = angle or 60.0
    local myCoords     = GetEntityCoords(ped)
    local targetCoords = GetEntityCoords(target)
    local myHeading    = GetEntityHeading(ped)
    local dx = targetCoords.x - myCoords.x
    local dy = targetCoords.y - myCoords.y
    local targetAngle = math.deg(math.atan(dx, dy))
    if targetAngle < 0 then targetAngle = targetAngle + 360.0 end
    local diff = math.abs(myHeading - targetAngle)
    if diff > 180.0 then diff = 360.0 - diff end
    return diff < (angle / 2.0)
end
