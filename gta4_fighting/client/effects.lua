-- Combat Effects: camera shake, slow-mo, knockback, particles, sound

Effects = {}

function Effects.CameraShake(intensity, duration)
    if not Config.CameraShakeOnHit then return end
    intensity = intensity or Config.CameraShakeIntensity
    duration  = duration  or 200
    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", intensity)
    Citizen.SetTimeout(duration, function()
        StopGameplayCamShaking(true)
    end)
end

function Effects.SlowMotion(duration)
    if not Config.SlowMotionOnFinisher then return end
    duration = duration or Config.SlowMotionDuration
    SetTimeScale(0.3)
    Citizen.SetTimeout(duration, function()
        SetTimeScale(1.0)
    end)
end

function Effects.ScreenFlash(duration)
    duration = duration or 100
    AnimpostfxPlay("FocusOut", 0, false)
    Citizen.SetTimeout(duration, function()
        AnimpostfxStop("FocusOut")
    end)
end

function Effects.Stagger(ped, duration)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    duration = duration or 1000
    SetPedToRagdoll(ped, duration, duration, 0, true, true, false)
end

function Effects.Knockback(ped, attackerPed, force)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    force = force or 5.0

    local ac = GetEntityCoords(attackerPed)
    local tc = GetEntityCoords(ped)
    local dx, dy = tc.x - ac.x, tc.y - ac.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 0 then dx, dy = dx / dist, dy / dist end

    SetEntityVelocity(ped, dx * force, dy * force, 1.0)
end

function Effects.ImpactParticle(coords)
    RequestNamedPtfxAsset("core")
    local timeout = 100
    while not HasNamedPtfxAssetLoaded("core") and timeout > 0 do
        Citizen.Wait(10)
        timeout = timeout - 1
    end
    if not HasNamedPtfxAssetLoaded("core") then return end

    UseParticleFxAssetNextCall("core")
    local fx = StartParticleFxLoopedAtCoord(
        "bul_carmetal",
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0, 0.5,
        false, false, false, false)

    Citizen.SetTimeout(200, function()
        StopParticleFxLooped(fx, false)
        RemoveNamedPtfxAsset("core")
    end)
end

function Effects.PunchSound(ped, hitType)
    if hitType == "heavy" or hitType == "finishing" or hitType == "counter" then
        PlaySoundFromEntity(-1, "Punch_Low", ped, "GTAO_FM_Events_Soundset", false, 0)
    else
        PlaySoundFromEntity(-1, "Punch_Stomach", ped, "GTAO_FM_Events_Soundset", false, 0)
    end
end

function Effects.ApplyDamage(ped, amount)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    ApplyDamageToPed(ped, math.floor(amount), false)
end

-- Return a table of effect intensities keyed by hit type
function Effects.GetIntensity(hitType)
    if hitType == "finishing" then
        return { shake = 0.4, knockback = 12.0, stagger = 2500, slowmo = true,  flash = true  }
    elseif hitType == "heavy" then
        return { shake = 0.25, knockback = 7.0,  stagger = 1500, slowmo = false, flash = true  }
    elseif hitType == "counter" then
        return { shake = 0.3,  knockback = 9.0,  stagger = 2000, slowmo = true,  flash = true  }
    else -- light
        return { shake = 0.1,  knockback = 3.0,  stagger = 0,    slowmo = false, flash = false }
    end
end
