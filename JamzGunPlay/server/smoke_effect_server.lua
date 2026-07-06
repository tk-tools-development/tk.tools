RegisterNetEvent('smokeEffect:sync', function(netId, muzzlePos, heading, scale, evolution, useLooped, attachToEntity, duration, fadeIn, fadeInDuration, fadeOut, fadeOutDuration)
    local src = source
    TriggerClientEvent('smokeEffect:playForPlayer', -1, src, netId, muzzlePos, heading, scale, evolution, useLooped, attachToEntity, duration, fadeIn, fadeInDuration, fadeOut, fadeOutDuration)
end)
