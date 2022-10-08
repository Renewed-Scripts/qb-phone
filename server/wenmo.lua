local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:wenmo_givemoney_toID', function(data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local OtherPly = QBCore.Functions.GetPlayer(tonumber(data.ID))
    local Amount = tonumber(data.Amount)
    local Reason = data.Reason

    if src == tonumber(data.ID) then return end

    if not OtherPly then return TriggerClientEvent('QBCore:Notify', src, 'Player not Online', "error") end

    local txt = "Wenmo: "..Reason
    
    if Ply.PlayerData.money.bank >= Amount then
        Ply.Functions.RemoveMoney('bank', Amount, txt)
        OtherPly.Functions.AddMoney('bank', Amount, txt)

        if Config.RenewedBanking then
            local cid = Ply.PlayerData.citizenid
            local name = ("%s %s"):format(Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname)

            local cid2 = OtherPly.PlayerData.citizenid
            local name2 = ("%s %s"):format(OtherPly.PlayerData.charinfo.firstname, OtherPly.PlayerData.charinfo.lastname)

            exports['Renewed-Banking']:handleTransaction(cid, "Wenmo Transaction", Amount, txt, name2, name, "withdraw")
            exports['Renewed-Banking']:handleTransaction(cid2, "Wenmo Transaction", Amount, txt, name, name2, "deposit")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, 'You don\'t have enough money!', "error") -- replace this with Phone Notify
    end
end)
