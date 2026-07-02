-- GTA IV Style Lock-On Targeting System

Targeting = {}
Targeting.CurrentTarget = nil
Targeting.IsLockedOn = false

-- Find the closest valid ped in range with line of sight
function Targeting.FindTarget(playerPed, playerCoords)
    local closestPed = nil
    local closestDist = Config.LockOnSearchRange

    -- Scan world peds
    local handle, ped = FindFirstPed()
    local success = true
    repeat
        if ped ~= playerPed and DoesEntityExist(ped) and not IsEntityDead(ped) then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(playerCoords - pedCoords)
            if dist < closestDist and HasEntityClearLosToEntity(playerPed, ped, 17) then
                closestDist = dist
                closestPed = ped
            end
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)

    -- Also check other players
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local otherPed = GetPlayerPed(playerId)
            if DoesEntityExist(otherPed) and not IsEntityDead(otherPed) then
                local pedCoords = GetEntityCoords(otherPed)
                local dist = #(playerCoords - pedCoords)
                if dist < closestDist and HasEntityClearLosToEntity(playerPed, otherPed, 17) then
                    closestDist = dist
                    closestPed = otherPed
                end
            end
        end
    end

    return closestPed, closestDist
end

function Targeting.LockOn(target)
    if target and DoesEntityExist(target) and not IsEntityDead(target) then
        Targeting.CurrentTarget = target
        Targeting.IsLockedOn = true
    end
end

function Targeting.Release()
    Targeting.CurrentTarget = nil
    Targeting.IsLockedOn = false
end

function Targeting.ValidateTarget(playerCoords)
    if not Targeting.CurrentTarget then return false end
    if not DoesEntityExist(Targeting.CurrentTarget) or IsEntityDead(Targeting.CurrentTarget) then
        Targeting.Release()
        return false
    end
    local dist = #(playerCoords - GetEntityCoords(Targeting.CurrentTarget))
    if dist > Config.LockOnSearchRange * 1.5 then
        Targeting.Release()
        return false
    end
    return true
end

-- Rotate the player to face the locked-on target
function Targeting.FaceTarget(playerPed)
    if not Targeting.IsLockedOn or not Targeting.CurrentTarget then return end
    if not DoesEntityExist(Targeting.CurrentTarget) then return end

    local tc = GetEntityCoords(Targeting.CurrentTarget)
    local pc = GetEntityCoords(playerPed)
    local heading = math.deg(math.atan(tc.x - pc.x, tc.y - pc.y))
    if heading < 0 then heading = heading + 360.0 end
    SetEntityHeading(playerPed, heading)
end

-- Draw a small marker above the target's head
function Targeting.DrawReticle()
    if not Config.ShowTargetReticle then return end
    if not Targeting.IsLockedOn or not Targeting.CurrentTarget then return end
    if not DoesEntityExist(Targeting.CurrentTarget) then return end

    local coords = GetEntityCoords(Targeting.CurrentTarget)
    local bone = GetPedBoneIndex(Targeting.CurrentTarget, 0x796E) -- SKEL_Head
    if bone ~= -1 then
        coords = GetPedBoneCoords(Targeting.CurrentTarget, bone, 0.0, 0.0, 0.0) + vector3(0.0, 0.0, 0.3)
    else
        coords = coords + vector3(0.0, 0.0, 1.0)
    end

    local c = Config.ReticleColor
    DrawMarker(0, coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.15, 0.15, 0.15,
        c.r, c.g, c.b, c.a,
        false, false, 2, false, nil, nil, false)
end

function Targeting.GetTargetDistance(playerCoords)
    if not Targeting.CurrentTarget or not DoesEntityExist(Targeting.CurrentTarget) then
        return 999.0
    end
    return #(playerCoords - GetEntityCoords(Targeting.CurrentTarget))
end
