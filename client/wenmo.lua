-- NUI Callback

RegisterNUICallback('wenmo_givemoney_toID', function(data)
    TriggerServerEvent('qb-phone:server:wenmo_givemoney_toID', data)
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus, reason)
    if type == "bank" then
        if isMinus then
            SendNUIMessage({
                action = "ChangeMoney_Wenmo",
                Color = "#f5a15b",
                Amount = "-$"..amount,
                Reason = reason,
            })
        else
            SendNUIMessage({
                action = "ChangeMoney_Wenmo",
                Color = "#8ee074",
                Amount = "+$"..amount,
                Reason = reason,
            })
        end
    end
end)