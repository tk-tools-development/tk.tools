RegisterNetEvent('upwardsShooting:sync', function(netId, x, y, z)
    local src = source
    TriggerClientEvent('upwardsShooting:playForPlayer', -1, src, netId, x, y, z)
end)
