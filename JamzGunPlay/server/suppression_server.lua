RegisterNetEvent('jamzgunplay:suppression:weaponFired', function(weaponHash)
    local src = source
    TriggerClientEvent('jamzgunplay:suppression:setShooterWeapon', -1, src, weaponHash)
end)
