local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:wenmo_givemoney_toID', function(data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local OtherPly = QBCore.Functions.GetPlayer(tonumber(data.ID))
    local Amount = tonumber(data.Amount)
    local Reason = data.Reason
    print(Reason)
    if not OtherPly then return TriggerClientEvent('QBCore:Notify', src, 'Player not Online', "error") end

    if Ply.PlayerData.money.bank and Ply.PlayerData.money.bank >= Amount then
        local txt = "Wenmo: "..Reason
        Ply.Functions.RemoveMoney('bank', Amount, txt)
        OtherPly.Functions.AddMoney('bank', Amount, txt)
    else
        TriggerClientEvent("QBCore:Notify", src, 'You don\'t have enough money!', "error") -- replace this with Phone Notify
    end
end)