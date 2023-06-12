-- NUI Callback

RegisterNUICallback('wenmo_givemoney_toID', function(data)
    TriggerServerEvent('qb-phone:server:wenmo_givemoney_toID', data)
end)

RegisterNetEvent('QBCore:Client:OnMoneyChange', function(type, amount, changeType, reason)
    if type == "bank" then
        if changeType == 'remove' then
            SendNUIMessage({
                action = "ChangeMoney_Wenmo",
                Color = "#f5a15b",
                Amount = "-$"..amount,
                Reason = reason or "",
            })
        else
            SendNUIMessage({
                action = "ChangeMoney_Wenmo",
                Color = "#8ee074",
                Amount = "+$"..amount,
                Reason = reason or "",
            })
        end
    end
end)
