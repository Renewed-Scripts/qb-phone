local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:wenmo_givemoney_toID', function(data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local OtherPly = QBCore.Functions.GetPlayer(tonumber(data.ID))
    local Amount = tonumber(data.Amount)
    local Reason = data.Reason
    if OtherPly then
        if Ply.PlayerData.money.bank then
            if Ply.PlayerData.money.bank >= Amount then
                Ply.Functions.RemoveMoney('bank', Amount, "Wenmo: "..Reason)
                OtherPly.Functions.AddMoney('bank', Amount,"Wenmo: "..Reason)
            else
                TriggerClientEvent("QBCore:Notify", src, 'You don\'t have enough money!', "error")
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player not Online', "error")
    end
end)