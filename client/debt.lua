local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('SendBillForPlayer_debt', function(data)
    TriggerServerEvent('qb-phone:server:SendBillForPlayer_debt', data)
end)

RegisterNUICallback('GetHasBills_debt', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetHasBills_debt', function(Has)
        cb(Has)
    end)
end)

RegisterNUICallback('debit_AcceptBillForPay', function(data)
    TriggerServerEvent('qb-phone:server:debit_AcceptBillForPay', data)
end)

RegisterNetEvent('qb-phone:RefreshPhoneForDebt', function()
    SendNUIMessage({
        action = "DebtRefresh",
    })
end)