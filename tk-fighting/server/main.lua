-- ============================================================
--  TK-FIGHTING  |  SERVER
--  Relays punch events between clients so hit reactions
--  are synced across the network.
-- ============================================================

RegisterNetEvent("tk-fighting:punchLanded")
AddEventHandler("tk-fighting:punchLanded", function(targetServerId, data)
    local src = source
    if not targetServerId or not data then return end

    local targetPlayer = tonumber(targetServerId)
    if not targetPlayer then return end

    if targetPlayer == src then return end

    TriggerClientEvent("tk-fighting:receiveHit", targetPlayer, data)

    if Config.Debug then
        print(("[TK-FIGHTING] Player %d hit player %d (%s, dmg=%d)"):format(
            src, targetPlayer, data.attackType or "?", data.damage or 0))
    end
end)

-- ============================================================
--  LOG (optional)
-- ============================================================
RegisterNetEvent("tk-fighting:logKnockout")
AddEventHandler("tk-fighting:logKnockout", function(targetServerId)
    local src = source
    print(("[TK-FIGHTING] KNOCKOUT: Player %d knocked out player %d"):format(src, targetServerId))
end)
