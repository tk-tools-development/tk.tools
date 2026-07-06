RegisterNetEvent('breathCondensation:breath', function(nearbyPlayers, serverId, isTalking)
    if type(nearbyPlayers) == 'table' then
        for targetId, _ in pairs(nearbyPlayers) do
            TriggerClientEvent('breathCondensation:breath', targetId, serverId, isTalking)
        end
    else
        TriggerClientEvent('breathCondensation:breath', -1, serverId, isTalking)
    end
end)
